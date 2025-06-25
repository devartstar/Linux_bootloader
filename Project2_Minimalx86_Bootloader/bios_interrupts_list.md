## 🧾 BIOS Interrupts – `AH` Cheatsheet

### 📺 `INT 0x10` – Video Services

| AH     | Function               | Description
|
| ------ | ---------------------- | --------------------------------------------
|
| `0x0E` | **Teletype Output**    | Print char in `AL` at cursor position
|
| `0x00` | Set video mode         | `AL` = mode number
|
| `0x02` | Set cursor position    | `DH` = row, `DL` = col
|
| `0x06` | Scroll window up       | `AL` = lines, `BH` = attr, `CH/DH/DL` = area
|
| `0x13` | Write string to screen | Block string write
|

---

### 💾 `INT 0x13` – Disk Services

| AH     | Function             | Description                                 |
| ------ | -------------------- | ------------------------------------------- |
| `0x00` | Reset disk system    | DL = drive (e.g., 0x80 = HDD)               |
| `0x02` | **Read sectors**     | AL = count, CH/CX/DH = CHS, ES\:BX = buffer |
| `0x03` | Write sectors        | Same as above                               |
| `0x08` | Get drive parameters | Returns drive geometry                      |

---

### ⌨️ `INT 0x16` – Keyboard Services

| AH     | Function              | Description                              |
| ------ | --------------------- | ---------------------------------------- |
| `0x00` | **Wait for keypress** | Result in `AL` (ASCII), `AH` (scan code) |
| `0x01` | Check for keypress    | ZF set if none                           |

---

### 🖨️ `INT 0x17` – Printer Services

| AH     | Function        | Description                      |
| ------ | --------------- | -------------------------------- |
| `0x00` | Print character | `AL` = char, `DX` = printer port |

---

### 🕹️ `INT 0x19` – Boot

| AH | Function  | Description             |
| -- | --------- | ----------------------- |
| –  | Bootstrap | Jump to BIOS bootloader |

---

### 🕒 `INT 0x1A` – RTC / Time Services

| AH     | Function               | Description                         |
| ------ | ---------------------- | ----------------------------------- |
| `0x00` | Get current clock time | Returns time in CX\:DX (BCD format) |

---

### 🧪 Sample Code Snippet:

```asm
mov ah, 0x0E
mov al, 'H'
int 0x10        ; Prints 'H' on screen
```


