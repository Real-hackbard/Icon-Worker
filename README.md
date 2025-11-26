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

Of course, it's not possible to modify the resources of all files because they have been processed differently. Some executables are heavily compressed or protected with special security programs that deny access to the resources, or attempting to access them would corrupt the file.

In simple terms, a Windows application's resources are separate from its program code. This distinction allows you to make significant changes to the interface without recompiling the entire application.

A resource is any non-executable data that is logically deployed with an application. A resource might be displayed in an application as error messages or as part of the user interface. Resources can contain data in a number of forms, including a collection of icons, strings, images, and data objects. Examples of resources include:

</br>

![resource](https://github.com/user-attachments/assets/08bf7973-edf3-4f15-ad3c-b29248285f2f)

</br>

* Error messages
* User interface elements: menus, dialogs, hot keys
* Icons and cursors
* Strings of text
* Multimedia files: sounds, images, and videos
* Product information and vendor details (copyrights, trademarks, origins)
* Data objects

Storing data in a resource section allows for changing the data without recompiling the entire application. When developers create an application, they embed resources directly into an executable file, producing a single EXE containing both code and resources. At run-time, the application can use these resource items again and again and they will never run out. The operation system also reads the file's resources when displaying the application icon on your desktop and showing the product information (version, file description and copyright notice).

# File structure:
An ICO or CUR file is made up of an ICONDIR ("Icon directory") structure, containing an ICONDIRENTRY structure for each image in the file, followed by a contiguous block of all image bitmap data (which may be in either Windows BMP format, excluding the BITMAPFILEHEADER structure, or in PNG format, stored in its entirety).

</br>

| Offset (bytes) | Field | Size (bytes) | Description |
| :-----------: | :-----------: | :-----------: | :----------- |
| 0     | idReserved     | 2     | Reserved. Must be 0.     |
| 2     | idType     | 2     | Image type: 1 for ICO image, 2 for CUR image. Other values are invalid.     |
| 4     | idCount     | 2     | Number of images in the file.     |
| 6     | idEntries     | idCount * 16     | ICONDIRENTRY array. Each entry represents an image.     |

</br>

When changing icons, ensure the replacement icons are the same size and have the same number of colors as the original (e.g., a 16x16 4-bit icon cannot be replaced with a 32x32 8-bit icon). If you encounter a mismatch error when attempting to replace an icon that appears to be the same size and bit depth, the source icon likely has a different color depth (24-bit and 32-bit icons can look very similar).

Why is this important? The icon size and color depth in an EXE file are fixed, and there are typically multiple icons within a Windows executable. Here's an example of an Icon Group found in the Notepad application:

</br>

![notepadicons24](https://github.com/user-attachments/assets/59cbebb2-6c6f-408f-926e-189c43aac0b9)

</br>

When Windows displays a main application icon, such as for a desktop shortcut, it selects an icon based on specific criteria rather than the first one it finds. Carelessly swapping out icons of different sizes or color depths can result in visual artifacts.

# Icon Extractor:
Generally, the icons of all files can be extracted, even those whose resource area is heavily modified and full of files. It's not always just image files that are present, but rather a wider range of other files in the resource area. For example, the resource area of ​​Photoshop.exe contains 116 files.

</br>

![Icon Extractor](https://github.com/user-attachments/assets/030b5145-d427-4a11-8154-0155688f80ef)

</br>

The extractor can be used to extract all this information and find the icon.

# Windows Shell Icons:
shell32.dll is a Windows system file that functions as a dynamic link library (DLL). It contains functions for the Windows shell, including the desktop, the Start menu, the taskbar, and the ability to open files and web links. This DLL is an essential part of the operating system and cannot be easily removed.

This is also where the Windows icons, such as those displayed in Explorer, are located. When the icon view of a folder is to be changed, these exact icons are loaded from shell32.dll.

</br>

![shell](https://github.com/user-attachments/assets/a6bfd28a-f46d-4ff3-9e60-0104904a6750)

</br>

Here is a list of all icons in Windows 10. :
https://renenyffenegger.ch/development/Windows/PowerShell/examples/WinAPI/ExtractIconEx/shell32.html

Icon Worker can extract these symbols and import the executables.

# Cache:
If the icon of an executable file has been changed, it is usually not immediately visible, and the old icon is still displayed. This is because the [Windows cache](https://en.wikipedia.org/wiki/Cache_(computing)) still contains the old information about this file and has not been updated. Only when the file is renamed or moved, or the system is restarted, is the cache information renewed.

Cache writes must eventually be propagated to the backing store. The timing for this is governed by the write policy. The two primary write policies are:

* Write-through: Writes are performed synchronously to both the cache and the backing store.
* Write-back: Initially, writing is done only to the cache. The write to the backing store is postponed until the modified content is about to be replaced by another cache block.

</br>

![Write-through_with_no-write-allocation svg](https://github.com/user-attachments/assets/11501f0c-db73-4b73-9f67-6c704b6eacd5)

</br>

A write-back cache is more complex to implement since it needs to track which of its locations have been written over and mark them as dirty for later writing to the backing store. The data in these locations are written back to the backing store only when they are evicted from the cache, a process referred to as a lazy write. For this reason, a read miss in a write-back cache may require two memory accesses to the backing store: one to write back the dirty data, and one to retrieve the requested data. Other policies may also trigger data write-back. The client may make many changes to data in the cache, and then explicitly notify the cache to write back the data.



