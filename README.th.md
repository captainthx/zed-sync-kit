# Zed Sync Kit

[English](./README.md) | ภาษาไทย

ชุดสคริปต์แบบง่ายสำหรับ sync config ของ `Zed` ข้ามเครื่องของตัวเองผ่าน GitHub

## ทางลัดที่ง่ายสุด

ต้องมี `gh` ก่อน และ login ไว้แล้ว:

```bash
gh auth login
```

ที่เครื่องหลัก:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export
```

ที่เครื่องใหม่:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- install
```

สิ่งที่ flow นี้ทำให้:

- ถ้า `zed-config` ยังไม่มี `export` จะสร้าง repo private ให้เอง
- `export` จะ copy config ของ Zed แล้ว push ขึ้น repo นั้น
- `install` จะดึง config จาก repo นั้นมาลงเครื่องใหม่
- `install` ใช้ได้หลังจากรัน `export` อย่างน้อยหนึ่งครั้งแล้ว

การแบ่งหน้าที่ของเครื่องมือ:

- `git` ใช้จัดการ repo บนเครื่อง: `add`, `commit`, `push`
- `gh` ใช้เข้าถึง GitHub: login, create repo, clone private repo

repo นี้เป็นฝั่ง public:

- เก็บ `bootstrap-zed.sh` สำหรับเรียกผ่าน `curl`
- เก็บตัวอย่างสคริปต์ `export` และ `install`
- เก็บคู่มือการใช้งาน

config จริงควรอยู่ในอีก repo หนึ่งที่เป็น **private**

## Sync อะไรบ้าง

เก็บเฉพาะ config ที่ควรย้ายข้ามเครื่อง:

- `settings.json`
- `keymap.json`
- `tasks.json`
- `themes/`

ไม่เก็บ:

- cache
- logs
- session
- recent projects
- binary ของ extensions

ถ้าอยากให้ extension มาครบทุกเครื่อง ให้ใช้ `auto_install_extensions` ใน `settings.json`

## โครงสร้าง repo

ใช้ 2 repo:

1. `zed-sync-kit`
   repo public สำหรับ README และ `bootstrap-zed.sh`
2. `zed-config`
   repo private สำหรับเก็บ config จริง และสคริปต์ `export/install`

## ไฟล์ใน repo นี้

- `bootstrap-zed.sh`
- `export-zed-config.sh`
- `install-zed-config.sh`
- `test-local-flow.sh`

## Script Data Flow

`export-zed-config.sh`

1. อ่าน config ของ Zed จากเครื่องหลัก
2. copy ไปไว้ที่ `zed/` ใน repo `private zed-config`
3. ถ้าใส่ `--push` จะ `git add`, `git commit`, `git push` ให้ต่อเลย

```text
config บนเครื่องหลัก -> private zed-config repo/zed -> GitHub
```

`install-zed-config.sh`

1. อ่านไฟล์จาก `zed/` ใน repo `private zed-config`
2. backup config ปัจจุบันของเครื่องนั้นก่อน
3. copy ไฟล์ลง path config ของ Zed

```text
GitHub private zed-config repo/zed -> config Zed บนเครื่องปลายทาง
```

`bootstrap-zed.sh`

1. โหลดจาก repo public `zed-sync-kit`
2. ใช้ `gh` ที่ login อยู่ไป clone repo `private zed-config` ลง temp dir
3. รัน `install-zed-config.sh`
4. ลบ temp dir ทิ้ง

สรุปสั้น:

- `export/install` ใช้ `git` เพราะทำงานกับ repo local
- `bootstrap` ใช้ `gh` เพราะต้องเข้าถึง private repo บน GitHub

## วิธีใช้งาน

### One-liner flow

ถ้าอยากสร้าง repo ล่วงหน้าเองแบบ explicit:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- init
```

export จากเครื่องหลัก:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export
```

install บนเครื่องใหม่:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- install
```

ถ้าจะ override ชื่อ repo:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export --repo YOUR_USER/zed-config
```

ถ้าจะทดสอบบน branch แยก:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export --repo YOUR_USER/zed-config --ref smoke-test
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- install --repo YOUR_USER/zed-config --ref smoke-test --target /tmp/zed-test
```

ถ้าจะชี้ source path เอง:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export --source /custom/zed/path
```

ถ้าจะชี้ target path เอง:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- install --target /custom/zed/path
```

### Manual flow

### 1. สร้าง private repo สำหรับ config

```bash
gh repo create YOUR_USER/zed-config --private --clone
cd zed-config
cp /path/to/zed-sync-kit/export-zed-config.sh .
cp /path/to/zed-sync-kit/install-zed-config.sh .
mkdir -p zed
git add .
git commit -m "Initialize Zed config repo"
git push
```

### 2. export จากเครื่องหลัก

```bash
cd /path/to/zed-config
./export-zed-config.sh --push
```

ถ้าอยากกำหนด commit message เอง:

```bash
./export-zed-config.sh --push --message "Update Zed config"
```

### 3. install บนเครื่องใหม่

ก่อนรัน:

1. ติดตั้ง `gh`
2. รัน `gh auth login`
3. ติดตั้ง `Zed` หนึ่งครั้ง

จากนั้นรัน:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/zed-sync-kit/main/bootstrap-zed.sh | bash -s -- YOUR_USER/zed-config
```

ถ้าจะบังคับ path ปลายทาง:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/zed-sync-kit/main/bootstrap-zed.sh | bash -s -- YOUR_USER/zed-config --target /custom/zed/path
```

ถ้าจะทดสอบจาก branch แยก:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/zed-sync-kit/main/bootstrap-zed.sh | bash -s -- YOUR_USER/zed-config --ref smoke-test --target /tmp/zed-test
```

## การทดสอบ

ทดสอบ local:

```bash
bash ./test-local-flow.sh
```

สคริปต์จะสร้าง home จำลอง 2 ชุด, export จากชุดแรก, install ลงชุดที่สอง, แล้วเทียบผลให้

## หมายเหตุ

- `curl | bash` ยังหมายถึงการรัน code จาก network อยู่ดี ควรให้ `bootstrap` สั้นและอ่านง่าย
- วิธีนี้คือ sync แบบ config-as-code ไม่ใช่ account sync แบบ VS Code
- ถ้างงว่าเมื่อไรใช้ `git` หรือ `gh`: `git` = repo บนเครื่อง, `gh` = GitHub
