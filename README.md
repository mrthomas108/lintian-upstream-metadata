lintian-upstream-metadata
=========================
 
 
 Lintian-check based on DEP12 (http://dep.debian.net/deps/dep12/). Checks if debian/upstream file is present and if so, checks if the file contains valid YAML data.
 
 
Requirements
============

 * libtest-yaml-valid-perl
 
Usage
=====
 
 
<pre>
lintian --pedantic --include-dir=/path/to/lintian-upstream-metadata --profile debian/metadata sourcepackage.changes
</pre>
