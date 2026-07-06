# Zed Sync Kit

[English](./README.md) | ภาษาไทย

sync config ของ `Zed` ข้ามเครื่องของตัวเองผ่าน `gh`, `git` และสคริปต์ public ตัวเดียว

## สิ่งที่ต้องมี

- `gh`
- `git`
- `bash`
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
- push config ขึ้น repo private นั้น

`install`

- รันบนเครื่องใหม่
- อ่าน config จาก `YOUR_GH_USER/zed-config`
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
- `git` ทำงานกับ repo บนเครื่อง ส่วน `gh` ใช้เข้าถึง GitHub และ private repo
- วิธีนี้เป็น config sync ไม่ใช่ account sync แบบ VS Code
