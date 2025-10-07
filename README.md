# 🧩 DriverCheck GUI

**DriverCheck GUI** es una herramienta en **bash** que permite verificar los controladores instalados y faltantes en sistemas **Linux**, con una interfaz interactiva basada en **Whiptail**.

Ideal para usuarios de **Arch Linux**, **CachyOS**, **Manjaro**, **Ubuntu**, **Fedora** y otras distribuciones.

---

## 🚀 Características

✅ Detección automática de distribución  
✅ Instalación automática de dependencias  
✅ Interfaz gráfica en consola con **Whiptail**  
✅ Detección de:
- 🖥️ GPU  
- 🌐 Red (Ethernet / Wi-Fi)  
- 🔊 Audio  
- 🧩 USB  
- 📡 Bluetooth  

✅ Exportación de informe completo (`driver-report.txt`)  
✅ Totalmente portable y sin dependencias externas  

---

## 📦 Instalación

### 🔹 Opción 1: Clonar el repositorio
```bash
git clone https://github.com/<TU_USUARIO>/driver-check-gui.git
cd driver-check-gui
chmod +x driver-check-gui.sh

🔹 Opción 2: Descargar directamente
wget https://raw.githubusercontent.com/<TU_USUARIO>/driver-check-gui/main/driver-check-gui.sh
chmod +x driver-check-gui.sh
```
---
## 🧠 Uso
Ejecuta el script:
```bash
./driver-check-gui.sh
```
---
Aparecerá un menú interactivo:
```bash
🔧 DriverCheck Linux v2.0
1) GPU
2) Red (Ethernet/Wi-Fi)
3) Audio
4) Dispositivos USB
5) Bluetooth
6) Informe completo
7) Exportar informe
0) Salir
```
