# Amikai's dotfiles
![](https://i.imgur.com/bu2b5hw.png)

# 安裝
⚠️ Warning: 如果你想試試看這些 dotfiles，千萬不要直接執行，必須看懂之後進行修改，
因為 dotfiles 是非常個人化的設定，很多設定不一定適用於你，我寫的是屬於我的 dotfiles，並不是通用的 dotfiles framework

📝 為了讓大家方便使用，[這裡](https://github.com/amikai/dotfiles/labels/documentation)會為大家進行解說

假設你想將設定放在 `$HOME/dotfiles`:

Step 1. 下載:
```
git clone https://github.com/amikai/dotfiles "$HOME/dotfiles"
```
Step 2. 進入 dotfiles 資料夾並且安裝:
```
cd "$HOME/dotfiles" && make
```
# 目錄結構

- `tools/`: 系統使用的工具
  - `tools/basic.sh`: 基本工具 (盡量不要更改) 
  - `tools/extra.sh`: 個人偏好的工具 (用力的改)
  - `tools/xxx.sh`: 根據每個工具所做出的設定
- `apps/`: macOS 應用程式
  - `apps/basic.sh`: 基本的應用程式 ex: ITerm2、Chrome
  - `apps/extra.sh`: 個人偏好的應用程式 ex: Line、telegram、evernote
  - `tools/xxx.sh`: 根據每個應用程式所做出的設定
- `runcom`: shell 會載入的資訊 ex: .bash_profile、.bashrc
- `system`: .bash_profile 會載入的檔案
- `macos`: macos 的系統設定

# FAQs

# 感謝
- `macos`檔案的內容是從 [mathiasbynens .osx](https://github.com/mathiasbynens/dotfiles/blob/master/.osx) 搬過來並且做個人化的修改
- 目錄結構參考了 [webpro's dotfiles](https://github.com/webpro/dotfiles)
