# XSLT snippets

All snippets below can be tested with the [Saxon XSLT processor](http://www.saxonica.com "Saxon XSLT processor").

**Tip**

A convenient alias can be set as such:

    $ alias sxn='java -classpath <saxon-install-dir>/libexec/saxon9he.jar net.sf.saxon.Transform'

To make this alias persistent (after reboot), add it to `.bash_profile` in your
home directory.

Transformations can then simply be performed with:

    $ sxn -xsl:xslt_file.xslt -s:input_file.xml

Since Saxon always requires an input file, a `dummy.xml` file is included.

## exif-to-iso-date

EXIF (Exchangeable image file format) provides a DateTime tag that is the date
and time of image creation. The format is `YYYY:MM:DD HH:MM:SS` with time shown
in 24-hour format, and the date and time separated by one blank character. This
XSLT-snippet provides two nearly identical functions:
- `mm:exif-to-iso-datetime`: which parses it's output as an `xs:date`. Meaning
  the input should be a valid date as well (no `199x:xx:xx` type dates)
- `mm:exif-to-iso-datestring`: which parses it's output as an `xs:string` which
  means anything goes as input as long as it conforms to the structure
 `xxxx:xx:xx xx:xx:xx`.

 **Run**

     $ sxn -xsl:exif-to-iso-date.xslt -s:dummy.xml
