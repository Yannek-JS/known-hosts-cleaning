# known-hosts-cleaning
A Bash script that makes cleaning up of SSH known_hosts file easier.

The script modifies user's known_hosts file. It lets you remove all entries starting with IP address just in one move from this file.
You can also specify a pattern (string or regular expression) that is use for finding and removing the entries that match it. 

**Known issues**
1. Backslash `\` needs to be entered twice to be treated as escape character in regular expressions, e.g. when you are about to remove all entries starting wit square bracket `[`, you need to enter the pattern like this: `^\\[`

**Requirements:**

* Bash version >= 4.0 should be fine for this script, however script is more verbose with versions >= 4.2. To check your Bash version, run 
```bash --version```
* following packages are required, however, they are included in most of Linux distro configurations by default: `grep`, `sed`, `gawk` 

<br />

Environment used for testing the script:

* Linux 3.10.0-1160.31.1.el7.x86_64 #1 SMP, PRETTY_NAME="CentOS Linux 7 (Core)"
* GNU bash, version 4.2.46(2)-release (x86_64-redhat-linux-gnu)
* grep (GNU grep) 2.20
* sed (GNU sed) 4.2.2
* GNU Awk 4.0.2

