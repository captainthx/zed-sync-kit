# Zed Sync Kit

[English](./README.md) | ภาษาไทย

sync config ของ `Zed` ข้ามเครื่องของตัวเองผ่าน `gh`, `git`, สคริปต์ public ตัวเดียว และไฟล์ secret แบบ local-only

## สิ่งที่ต้องมี

- `gh`
- `git`
- `bash`
- `node` หรือ `bun`
- เครื่องปลายทางติดตั้ง `Zed` แล้ว
- รัน `gh auth login` แล้ว

## เริ่มเร็วสุด

เครื่องหลัก:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export
```

เครื่องใหม่:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- install
```

## มันทำงานยังไง

`export`

- รันบนเครื่องหลัก
- ถ้ายังไม่มี `YOUR_GH_USER/zed-config` มันจะสร้าง private repo นี้ให้เอง
- อ่าน config ของ Zed จากเครื่องหลัก
- ย้าย secret ที่รองรับไปไว้ใน `settings.local.json`
- push config ขึ้น repo private นั้น

`install`

- รันบนเครื่องใหม่
- อ่าน config จาก `YOUR_GH_USER/zed-config`
- merge `settings.local.json` ของเครื่องนั้นถ้ามี
- backup config เดิมของเครื่องนั้นก่อน
- ลง config ชุดที่ sync ไว้ให้ในเครื่อง

`init`

- ไม่จำเป็นเสมอไป
- ใช้สร้าง private repo `zed-config` ล่วงหน้า

## Sync อะไรบ้าง

- `settings.json`
- `keymap.json`
- `tasks.json`
- `themes/`

ไม่ sync:

- cache
- logs
- sessions
- state ที่ผูกกับเครื่อง
- secret ใน `settings.local.json`

## Local Secrets

`zed-sync` ใช้ `~/.config/zed/settings.local.json` เป็นไฟล์ local-only override

- ไฟล์นี้จะไม่ถูก push ไป `zed-config`
- ตอน `install` จะ merge กลับเข้า `settings.json` ของเครื่องนั้น
- ตอน `export` repo จะได้เฉพาะ config ที่ sanitize แล้ว

v1 จะดึงเฉพาะ key ใต้ `context_servers.*.settings` ที่ลงท้ายด้วย:

- `_key`
- `_token`
- `_secret`

ตัวอย่าง:

```json
{
  "context_servers": {
    "mcp-server-context7": {
      "settings": {
        "context7_api_key": "your-local-secret"
      }
    }
  }
}
```

## คำสั่งหลัก

สร้าง private repo เองล่วงหน้า:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- init
```

export config:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export
```

install config:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- install
```

## ตัวเลือกที่ใช้บ่อย

ใช้ชื่อ repo เอง:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export --repo YOUR_USER/zed-config
```

ชี้ source path เองตอน export:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export --source /custom/zed/path
```

ชี้ target path เองตอน install:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- install --target /custom/zed/path
```

ทดสอบบน branch แยก:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export --ref smoke-test
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- install --ref smoke-test --target /tmp/zed-test
```

## หมายเหตุ

- `install` ใช้ได้หลังจากรัน `export` อย่างน้อยหนึ่งครั้งแล้ว
- `settings.local.json` เป็นไฟล์ของ `zed-sync` ไม่ใช่ไฟล์เสริมที่ Zed อ่านเองโดยตรง
- `git` ทำงานกับ repo บนเครื่อง ส่วน `gh` ใช้เข้าถึง GitHub และ private repo
- วิธีนี้เป็น config sync ไม่ใช่ account sync แบบ VS Code
