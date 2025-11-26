# Icon-Worker:

</br>

![Compiler](https://github.com/user-attachments/assets/a916143d-3f1b-4e1f-b1e0-1067ef9e0401) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ![10 Seattle](https://github.com/user-attachments/assets/c70b7f21-688a-4239-87c9-9a03a8ff25ab) ![10 1 Berlin](https://github.com/user-attachments/assets/bdcd48fc-9f09-4830-b82e-d38c20492362) ![10 2 Tokyo](https://github.com/user-attachments/assets/5bdb9f86-7f44-4f7e-aed2-dd08de170bd5) ![10 3 Rio](https://github.com/user-attachments/assets/e7d09817-54b6-4d71-a373-22ee179cd49c)   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![10 4 Sydney](https://github.com/user-attachments/assets/e75342ca-1e24-4a7e-8fe3-ce22f307d881) ![11 Alexandria](https://github.com/user-attachments/assets/64f150d0-286a-4edd-acab-9f77f92d68ad) ![12 Athens](https://github.com/user-attachments/assets/59700807-6abf-4e6d-9439-5dc70fc0ceca)  
![Components](https://github.com/user-attachments/assets/d6a7a7a4-f10e-4df1-9c4f-b4a1a8db7f0e) : ![UntUtils pas](https://github.com/user-attachments/assets/0145302c-21de-4a64-9ba0-87b965ccabe0)  
![Discription](https://github.com/user-attachments/assets/4a778202-1072-463a-bfa3-842226e300af) &nbsp;&nbsp;: ![Icon Worker](https://github.com/user-attachments/assets/84d15054-1313-4297-b2f5-c1c4f4efcba5)  
![Last Update](https://github.com/user-attachments/assets/e1d05f21-2a01-4ecf-94f3-b7bdff4d44dd) &nbsp;: ![112025](https://github.com/user-attachments/assets/6c049038-ad2c-4fe3-9b7e-1ca8154910c2)  
![License](https://github.com/user-attachments/assets/ff71a38b-8813-4a79-8774-09a2f3893b48) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ![Freeware](https://github.com/user-attachments/assets/1fea2bbf-b296-4152-badd-e1cdae115c43)

</br>

The ICO file format is an [image file format](https://en.wikipedia.org/wiki/Image_file_format) for [computer icons](https://en.wikipedia.org/wiki/Icon_(computing)) in Microsoft Windows. ICO files contain one or more small images at multiple sizes and [color depths](https://en.wikipedia.org/wiki/Color_depth), such that they may be [scaled](https://en.wikipedia.org/wiki/Image_scaling) appropriately. In Windows, all [executables](https://en.wikipedia.org/wiki/Executable) that display an icon to the user, on the desktop, in the Start Menu, or in file Explorer, must carry the icon in ICO format.

Icons introduced in [Windows 1.0](https://en.wikipedia.org/wiki/Windows_1.0) were 32×32 pixels in size and were monochrome. Support for 16 colors was introduced in Windows 3.0.[citation needed]

Win32 introduced support for storing icon images of up to [16.7 million colors](https://en.wikipedia.org/wiki/Color_depth#True_color_(24-bit)) (TrueColor) and up to 256×256 pixels in dimensions. Windows 95 also introduced a new Device Independent Bitmap (DIB) engine. However, 256 color was the default icon color depth in Windows 95. It was possible to enable [65535 color (Highcolor)](https://en.wikipedia.org/wiki/RGB_color_model#16-bit_RGB_(Highcolor)) icons by either modifying the Shell Icon BPP value in the registry or by purchasing Microsoft Plus! for Windows 95. The Shell Icon Size value allows using larger icons in place of 32×32 icons and the Shell Small Icon Size value allows using custom sizes in place of 16×16 icons. Thus, a single icon file could store images of any size from 1×1 pixel up to 256×256 pixels (including non-square sizes) with 2 (rarely used), 16, 256, 65535, or 16.7 million colors; but the shell could not display very large sized icons. The notification area of the Windows taskbar was limited to 16 color icons by default until Windows Me when it was updated to support high color icons.

</br>

![iconWorker](https://github.com/user-attachments/assets/a9070f52-1b73-4761-9653-b6f8e2d8cf90)

</br>

# File structure:
An ICO or CUR file is made up of an ICONDIR ("Icon directory") structure, containing an ICONDIRENTRY structure for each image in the file, followed by a contiguous block of all image bitmap data (which may be in either Windows BMP format, excluding the BITMAPFILEHEADER structure, or in PNG format, stored in its entirety).

</br>

| Offset (bytes) | Field | Size (bytes) | Description |
| :-----------: | :-----------: | :-----------: | :-----------: |
| 0     | idReserved     | 2     | Reserved. Must be 0.     |
| 2     | idType     | 2     | Image type: 1 for ICO image, 2 for CUR image. Other values are invalid.     |
| 4     | idCount     | 2     | Number of images in the file.     |
| 6     | idEntries     | idCount * 16     | ICONDIRENTRY array. Each entry represents an image.     |













