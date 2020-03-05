# XSLT snippets

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
