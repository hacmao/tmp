# Download file shellcode  

Chúng ta sẽ sử dụng hàm `URLDownloadToFile` để download file. Thư viện này nằm trong thư viện `urlmon.dll`.  
Tuy nhiên cần lưu ý, trước khi load thư viện `urlmon.dll` chúng ta cần phải load thư viện `VCRUNTIME140D.dll`.   
Mình nhận ra điều này nhờ viết một file chỉ sử dụng hàm `URLDownloadToFile` rồi xem trong `CFFExplorer` nó import những thư viện gì. Sau đó mình nghi ngờ thằng `VCRUNTIME140D.dll` này, thử load bằng asm thì thành công =)) Rồi tiếp tục thực hiện như bình thường.   
