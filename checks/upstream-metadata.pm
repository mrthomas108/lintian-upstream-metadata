
# upstream-metadata -- lintian check script -*- perl -*-
#
# Copyright (C) 2013 Simon Kainz <simon@familiekainz.at>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, you can find it on the World Wide
# Web at http://www.gnu.org/copyleft/gpl.html, or write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
# MA 02110-1301, USA.

package Lintian::upstream_metadata;
use strict;
use warnings;

use Lintian::Collect;
use Lintian::Tags qw(tag);

use Test::More;
use Test::YAML::Valid;

use YAML qw(Load LoadFile);

my @allowed_fields=("Archive","Bug-Database","Bug-Submit","Cite-As","Changelog",
		    "Contact","Donation","FAQ","Funding","Gallery","Name","Homepage",
		    "Other-References","Reference","Reference-Author","Reference-Booktitle",
		    "Reference-DOI","Reference-Eprint","Reference-Journal","Reference-Number",
		    "Reference-Pages","Reference-PMID","Reference-Title","Reference-Type",
		    "Reference-URL","Reference-Volume","Reference-Year","Reference-Debian-package",
		    "Registration","Repository","Repository-Browse","Screenshots","Watch","Webservice");

sub run {
    
    my $pkg = shift;
    my $type = shift;
    my $info = shift;
    my $ufile = $info->debfiles('upstream');
    
    my $hashref;
    my $arrayref;
    my $string;
    my $allowed_fields_hash;
    my @invalid_fields;

    my $test_builder = Test::More->builder;
    $test_builder->output("/dev/null");
    $test_builder->failure_output("/dev/null");
    
    if (! -f $ufile) {
	tag 'debian-upstream-file-is-missing' unless ($info->native);
	return;
    }
    
#check if file is valid YAML
    

    yaml_file_ok($ufile);
    done_testing();

    my $test_result=$test_builder->{Test_Results}[0]{ok};

    if ($test_result == 0)
    {
	eval {LoadFile($ufile);};
	my $error_detail="Unknown error";
	if ($@)
	{
	    my @errlines=split(/\n/,$@);
    
	    $error_detail=$errlines[0].",".$errlines[1].",".$errlines[2];
	}

	tag 'debian-upstream-file-is-invalid',$error_detail;
	return;
    }
    
    open my $fh, '<',$ufile;
    my $yaml_string=join("",<$fh>);
    $yaml_string =~ s/^\s+\Z//m;
    $yaml_string.="\n";
    close($fh);
    
# ok, file is valid YAML, so check if there are unknown fields:
    foreach my $a (@allowed_fields)
    {
	$allowed_fields_hash->{$a}=1;
    }
    
    ($hashref, $arrayref, $string) = YAML::Load($yaml_string);
    
    foreach my $ref (keys %{$hashref})
    {
	if (! $allowed_fields_hash->{$ref})
	{
	    push (@invalid_fields,$ref);
	}
    }
    
    if (scalar(@invalid_fields) >0 )
    {
	tag 'debian-upstream-file-invalid-field', join(",",@invalid_fields);
    }
    
}

1;
