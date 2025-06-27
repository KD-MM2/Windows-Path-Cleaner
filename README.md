# PATH Environment Variable Cleanup Script

[English](#english-version) | [Tiếng Việt](#vietnamese-version)

---

## English Version

### Purpose

This PowerShell script is designed to clean up and optimize PATH environment variables in Windows by:

- Removing duplicate paths
- Categorizing paths into User PATH and System PATH
- Removing invalid paths (non-existent directories)
- Providing backup and preview capabilities before making changes

PATH cleanup helps:
- Speed up application startup
- Reduce executable search time
- Avoid conflicts between different versions of the same tool
- Maintain a clean and organized system PATH

### How It Works

#### 1. Data Collection
- Retrieves all User Environment PATH from registry
- Retrieves all System Environment PATH from registry
- Splits paths by `;` delimiter and removes empty entries

#### 2. Processing and Normalization
- **Merge**: Combines all paths from User and System PATH
- **Normalize**: Standardizes paths (expand environment variables, handle slashes, trim whitespace)
- **Deduplicate**: Removes duplicate paths (case-insensitive)
- **Validate**: Checks validity of each path

#### 3. Smart Categorization

The script uses an advanced categorization algorithm to identify User Path and System Path:

##### User Path is identified when the path:
- Starts with `%USERPROFILE%` or `C:\Users\<username>`
- Contains user-specific directories:
  - `AppData\Local`, `AppData\Roaming`, `AppData\LocalLow`
  - `%LOCALAPPDATA%`, `%APPDATA%`
  - `.local`, `bin`, `Scripts` in user directory
- Contains user-specific development tools:
  - `.cargo\bin` (Rust)
  - `.dotnet` (DotNet)
  - `go\bin` (Go)
  - `.npm`, `AppData\Roaming\npm` (Node.js)

##### System Path:
- All paths that don't belong to User Path category
- Usually system programs, global tools

#### 4. Apply Changes
- Updates User Environment PATH with paths categorized as User
- Updates System Environment PATH with paths categorized as System
- Creates backup before changes (if requested)

### Usage

#### System Requirements
- Windows 10/11 or Windows Server
- PowerShell 5.0 or higher
- **Administrator privileges** (required to modify System PATH)

#### Basic Syntax

```powershell
# Run with Administrator privileges
PowerShell -ExecutionPolicy Bypass -File "path-cleanup.ps1"
```

#### Parameters

##### `-DryRun`
Run in preview mode without making actual changes.

```powershell
.\path-cleanup.ps1 -DryRun
```
**Recommended**: Always run DryRun first to preview results.

##### `-Backup`
Create backup of current PATH before making changes.

```powershell
.\path-cleanup.ps1 -Backup
```

Backup will be saved in `PATH_Backup_<timestamp>` directory with 2 files:
- `USER_PATH.txt`: User PATH backup
- `SYSTEM_PATH.txt`: System PATH backup

##### `-Verbose`
Display detailed information during processing.

```powershell
.\path-cleanup.ps1 -Verbose
```

#### Common Usage Scenarios

##### 1. Preview before execution (Recommended)
```powershell
.\path-cleanup.ps1 -DryRun -Verbose
```

##### 2. Execute cleanup with backup
```powershell
.\path-cleanup.ps1 -Backup -Verbose
```

##### 3. Simple cleanup
```powershell
.\path-cleanup.ps1
```

### Results and Information Display

#### Summary Information
- Initial entry count (User + System)
- Entry count after processing
- Number of duplicates removed
- Number of invalid paths removed

#### Detailed Categorization (with -Verbose)
- List of User Paths
- List of System Paths
- List of invalid paths

#### Execution Status
- Confirmation when changes are successfully applied
- Backup location notification (if applicable)
- Instructions to restart applications for changes to take effect

### Important Notes

#### Safety
- **Always run `-DryRun` first**: To preview changes
- **Create backup**: Use `-Backup` to enable recovery if needed
- **Administrator privileges**: Script requires admin rights to modify System PATH

#### Limitations
- Script only removes non-existent paths, doesn't handle complex symbolic links
- Doesn't automatically detect portable applications
- Requires application restart or new command prompt for changes to take effect

#### Recovery
If issues occur after running the script:

1. **Use backup** (if created):
```powershell
# Restore User PATH
$userBackup = Get-Content "PATH_Backup_<timestamp>\USER_PATH.txt"
[Environment]::SetEnvironmentVariable("PATH", $userBackup, "User")

# Restore System PATH
$systemBackup = Get-Content "PATH_Backup_<timestamp>\SYSTEM_PATH.txt"
[Environment]::SetEnvironmentVariable("PATH", $systemBackup, "Machine")
```

2. **Use Windows System Restore Point**
3. **Manual editing** via System Properties > Environment Variables

### Troubleshooting

#### Common Errors

**"This script requires Administrator privileges"**
- Solution: Run PowerShell as Administrator

**"Execution Policy" error**
- Solution: Run with `PowerShell -ExecutionPolicy Bypass`

**Some paths are incorrectly categorized**
- Cause: May be due to symbolic links or junction points
- Solution: Manual verification and adjustment if needed

### Version and Updates

- **Version**: 1.0
- **Compatibility**: Windows 10/11, Windows Server 2016+
- **PowerShell**: 5.0+

### Conclusion

This script helps maintain a clean and organized PATH environment, improving system performance and reducing application conflicts. Always use `-DryRun` and `-Backup` to ensure safety when using.

---

## Vietnamese Version

---

## Vietnamese Version

### Mục đích

Script PowerShell này được thiết kế để dọn dẹp và tối ưu hóa các biến môi trường PATH trong Windows bằng cách:

- Loại bỏ các đường dẫn trùng lặp (duplicates)
- Phân loại đường dẫn thành User PATH và System PATH
- Xóa các đường dẫn không hợp lệ (không tồn tại)
- Cung cấp khả năng backup và preview trước khi thực hiện thay đổi

Việc dọn dẹp PATH giúp:
- Tăng tốc độ khởi động ứng dụng
- Giảm thời gian tìm kiếm executable
- Tránh xung đột giữa các phiên bản khác nhau của cùng một tool
- Duy trì hệ thống PATH sạch sẽ và có tổ chức

### Cách hoạt động

#### 1. Thu thập dữ liệu
- Lấy toàn bộ User Environment PATH từ registry
- Lấy toàn bộ System Environment PATH từ registry
- Tách các đường dẫn bằng dấu `;` và loại bỏ entries rỗng

#### 2. Xử lý và chuẩn hóa
- **Merge**: Gộp tất cả đường dẫn từ User và System PATH
- **Normalize**: Chuẩn hóa đường dẫn (expand biến môi trường, xử lý slash, trim khoảng trắng)
- **Deduplicate**: Loại bỏ các đường dẫn trùng lặp (không phân biệt hoa thường)
- **Validate**: Kiểm tra tính hợp lệ của từng đường dẫn

#### 3. Phân loại thông minh

Script sử dụng thuật toán phân loại nâng cao để xác định User Path và System Path:

##### User Path được xác định khi đường dẫn:
- Bắt đầu với `%USERPROFILE%` hoặc `C:\Users\<username>`
- Chứa các thư mục đặc trưng của user:
  - `AppData\Local`, `AppData\Roaming`, `AppData\LocalLow`
  - `%LOCALAPPDATA%`, `%APPDATA%`
  - `.local`, `bin`, `Scripts` trong thư mục user
- Chứa các công cụ development cụ thể của user:
  - `.cargo\bin` (Rust)
  - `.dotnet` (DotNet)
  - `go\bin` (Go)
  - `.npm`, `AppData\Roaming\npm` (Node.js)

##### System Path:
- Tất cả các đường dẫn không thuộc danh mục User Path
- Thường là các chương trình hệ thống, công cụ global

#### 4. Áp dụng thay đổi
- Cập nhật User Environment PATH với các đường dẫn được phân loại là User
- Cập nhật System Environment PATH với các đường dẫn được phân loại là System
- Tạo backup trước khi thay đổi (nếu được yêu cầu)

### Cách sử dụng

#### Yêu cầu hệ thống
- Windows 10/11 hoặc Windows Server
- PowerShell 5.0 trở lên
- **Quyền Administrator** (bắt buộc để sửa đổi System PATH)

#### Cú pháp cơ bản

```powershell
# Chạy với quyền Administrator
PowerShell -ExecutionPolicy Bypass -File "path-cleanup.ps1"
```

#### Các tham số (Parameters)

##### `-DryRun`
Chạy ở chế độ preview, không thực hiện thay đổi thực tế.

```powershell
.\path-cleanup.ps1 -DryRun
```
**Khuyến nghị**: Luôn chạy DryRun trước để xem preview kết quả.

##### `-Backup`
Tạo backup của PATH hiện tại trước khi thay đổi.

```powershell
.\path-cleanup.ps1 -Backup
```

Backup sẽ được lưu trong thư mục `PATH_Backup_<timestamp>` với 2 files:
- `USER_PATH.txt`: Backup User PATH
- `SYSTEM_PATH.txt`: Backup System PATH

##### `-Verbose`
Hiển thị thông tin chi tiết trong quá trình xử lý.

```powershell
.\path-cleanup.ps1 -Verbose
```

### Các kịch bản sử dụng phổ biến

#### 1. Preview trước khi thực hiện (Khuyển nghị)
```powershell
.\path-cleanup.ps1 -DryRun -Verbose
```

##### 2. Thực hiện cleanup với backup
```powershell
.\path-cleanup.ps1 -Backup -Verbose
```

##### 3. Cleanup đơn giản
```powershell
.\path-cleanup.ps1
```

### Kết quả và thông tin hiển thị

#### Thông tin tổng quan
- Số lượng entries ban đầu (User + System)
- Số lượng entries sau khi xử lý
- Số lượng duplicates đã loại bỏ
- Số lượng đường dẫn không hợp lệ đã xóa

#### Phân loại chi tiết (với -Verbose)
- Danh sách User Paths
- Danh sách System Paths  
- Danh sách đường dẫn không hợp lệ

#### Trạng thái thực hiện
- Confirmation khi áp dụng thay đổi thành công
- Thông báo vị trí backup (nếu có)
- Hướng dẫn restart ứng dụng để thay đổi có hiệu lực

### Lưu ý quan trọng

#### An toàn
- **Luôn chạy `-DryRun` trước**: Để xem preview thay đổi
- **Tạo backup**: Sử dụng `-Backup` để có thể khôi phục nếu cần
- **Quyền Administrator**: Script yêu cầu quyền admin để sửa đổi System PATH

#### Giới hạn
- Script chỉ xóa các đường dẫn không tồn tại, không xử lý symbolic links phức tạp
- Không tự động detect các ứng dụng portable
- Cần restart ứng dụng hoặc mở command prompt mới để thay đổi có hiệu lực

#### Khôi phục
Nếu có vấn đề sau khi chạy script:

1. **Sử dụng backup** (nếu đã tạo):
```powershell
# Khôi phục User PATH
$userBackup = Get-Content "PATH_Backup_<timestamp>\USER_PATH.txt"
[Environment]::SetEnvironmentVariable("PATH", $userBackup, "User")

# Khôi phục System PATH  
$systemBackup = Get-Content "PATH_Backup_<timestamp>\SYSTEM_PATH.txt"
[Environment]::SetEnvironmentVariable("PATH", $systemBackup, "Machine")
```

2. **Sử dụng System Restore Point** của Windows
3. **Chỉnh sửa thủ công** qua System Properties > Environment Variables

### Troubleshooting

#### Lỗi thường gặp

**"This script requires Administrator privileges"**
- Giải pháp: Chạy PowerShell as Administrator

**"Execution Policy" error** 
- Giải pháp: Chạy với `PowerShell -ExecutionPolicy Bypass`

**Một số đường dẫn bị phân loại sai**
- Nguyên nhân: Có thể do symbolic links hoặc junction points
- Giải pháp: Kiểm tra manual và điều chỉnh nếu cần

### Phiên bản và cập nhật

- **Version**: 1.0
- **Tương thích**: Windows 10/11, Windows Server 2016+
- **PowerShell**: 5.0+

### Kết luận

Script này giúp duy trì PATH environment sạch sẽ và có tổ chức, cải thiện hiệu suất hệ thống và giảm thiểu xung đột giữa các ứng dụng. Hãy luôn sử dụng `-DryRun` và `-Backup` để đảm bảo an toàn khi sử dụng.
