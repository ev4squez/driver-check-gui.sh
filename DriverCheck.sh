#!/usr/bin/env bash
# ======================================================
# 🧩 DriverCheck GUI v2.0
# Revisión y diagnóstico de controladores en Linux
# Con detección automática de distribución e instalación de dependencias
# Autor: Elvis V. - 2025
# ======================================================

# ------------------------------------------
# 🎯 Detectar distribución
# ------------------------------------------
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
  else
    DISTRO="desconocido"
  fi
}

# ------------------------------------------
# 🧰 Instalar dependencias según la distro
# ------------------------------------------
install_deps() {
  local pkgs=(whiptail pciutils usbutils)

  echo "🔍 Verificando dependencias..."
  for pkg in "${pkgs[@]}"; do
    if ! command -v "$pkg" &>/dev/null; then
      echo "⚙️  Instalando $pkg..."
      case "$DISTRO" in
        arch|manjaro|endeavouros|cachyos)
          sudo pacman -Sy --noconfirm $pkg ;;
        debian|ubuntu|linuxmint)
          sudo apt update && sudo apt install -y $pkg ;;
        fedora)
          sudo dnf install -y $pkg ;;
        opensuse*)
          sudo zypper install -y $pkg ;;
        *)
          echo "⚠️  No se reconoce la distribución ($DISTRO). Instala manualmente: $pkg"
          ;;
      esac
    fi
  done
}

# ------------------------------------------
# 🎨 Colores
# ------------------------------------------
GREEN="\Z2"
RED="\Z1"
YELLOW="\Z3"
RESET="\Zn"

# ------------------------------------------
# 🔍 Funciones de detección de drivers
# ------------------------------------------

check_gpu() {
  local info=$(lspci -k | grep -A3 -E "VGA|3D")
  local gpu=$(echo "$info" | grep -E "VGA|3D" | awk -F': ' '{print $2}')
  local driver=$(echo "$info" | grep "Kernel driver in use" | awk -F': ' '{print $2}')
  if [[ -z "$driver" ]]; then
    echo -e "❌ ${gpu}\n→ ${RED}Driver no detectado${RESET}"
  else
    echo -e "✅ ${gpu}\n→ ${GREEN}$driver${RESET}"
  fi
}

check_network() {
  local info=$(lspci -k | grep -A3 -E "Ethernet|Network")
  local result=""
  local name=""
  local drv=""
  while read -r line; do
    if [[ $line =~ "Ethernet" || $line =~ "Network" ]]; then
      name=$(echo "$line" | awk -F': ' '{print $2}')
    fi
    if [[ $line =~ "Kernel driver in use" ]]; then
      drv=$(echo "$line" | awk -F': ' '{print $2}')
      if [[ -z "$drv" ]]; then
        result+="❌ ${name}\n→ ${RED}Driver no detectado${RESET}\n\n"
      else
        result+="✅ ${name}\n→ ${GREEN}${drv}${RESET}\n\n"
      fi
    fi
  done <<< "$info"
  echo -e "$result"
}

check_audio() {
  local info=$(lspci -k | grep -A3 -i "Audio")
  local name=$(echo "$info" | grep "Audio" | awk -F': ' '{print $2}')
  local driver=$(echo "$info" | grep "Kernel driver in use" | awk -F': ' '{print $2}')
  if [[ -z "$driver" ]]; then
    echo -e "❌ ${name}\n→ ${RED}Driver no detectado${RESET}"
  else
    echo -e "✅ ${name}\n→ ${GREEN}${driver}${RESET}"
  fi
}

check_usb() {
  local info=$(lsusb)
  local result=""
  while read -r line; do
    result+="🔌 ${line}\n"
  done <<< "$info"
  echo -e "$result"
}

check_bluetooth() {
  local info=$(lsusb | grep -i bluetooth)
  if [[ -z "$info" ]]; then
    echo -e "❌ ${RED}No se detecta adaptador Bluetooth${RESET}"
  else
    echo -e "✅ ${GREEN}${info}${RESET}"
  fi
}

# ------------------------------------------
# 📋 Generar informe
# ------------------------------------------
generate_report() {
  local report_path="$HOME/driver-report.txt"
  echo "==============================" > "$report_path"
  echo "🧩 DriverCheck Report - $(date)" >> "$report_path"
  echo "==============================" >> "$report_path"
  echo "" >> "$report_path"

  echo "🖥️ GPU:" >> "$report_path"
  check_gpu >> "$report_path"
  echo "" >> "$report_path"

  echo "🌐 Red:" >> "$report_path"
  check_network >> "$report_path"
  echo "" >> "$report_path"

  echo "🔊 Audio:" >> "$report_path"
  check_audio >> "$report_path"
  echo "" >> "$report_path"

  echo "🧩 USB:" >> "$report_path"
  check_usb >> "$report_path"
  echo "" >> "$report_path"

  echo "📡 Bluetooth:" >> "$report_path"
  check_bluetooth >> "$report_path"

  whiptail --title "📁 Informe generado" --msgbox "El informe se guardó en:\n\n$report_path" 12 70
}

# ------------------------------------------
# 🧠 Menú principal con Whiptail
# ------------------------------------------
main_menu() {
  while true; do
    CHOICE=$(whiptail --title "🔧 DriverCheck Linux v2.0" --menu "Seleccione una categoría:" 20 70 10 \
      "1" "🖥️  GPU" \
      "2" "🌐 Red (Ethernet/WiFi)" \
      "3" "🔊 Audio" \
      "4" "🧩 Dispositivos USB" \
      "5" "📡 Bluetooth" \
      "6" "📋 Informe completo" \
      "7" "💾 Exportar informe a archivo" \
      "0" "❌ Salir" \
      3>&1 1>&2 2>&3)

    exitstatus=$?
    [[ $exitstatus -ne 0 || $CHOICE == "0" ]] && break

    case $CHOICE in
      1)
        output=$(check_gpu)
        whiptail --title "GPU" --scrolltext --msgbox "$(echo -e "$output")" 20 70 ;;
      2)
        output=$(check_network)
        whiptail --title "Red" --scrolltext --msgbox "$(echo -e "$output")" 20 70 ;;
      3)
        output=$(check_audio)
        whiptail --title "Audio" --scrolltext --msgbox "$(echo -e "$output")" 20 70 ;;
      4)
        output=$(check_usb)
        whiptail --title "Dispositivos USB" --scrolltext --msgbox "$(echo -e "$output")" 20 70 ;;
      5)
        output=$(check_bluetooth)
        whiptail --title "Bluetooth" --scrolltext --msgbox "$(echo -e "$output")" 20 70 ;;
      6)
        all=$(echo -e "🖥️ GPU:\n$(check_gpu)\n\n🌐 Red:\n$(check_network)\n\n🔊 Audio:\n$(check_audio)\n\n🧩 USB:\n$(check_usb)\n\n📡 Bluetooth:\n$(check_bluetooth)")
        whiptail --title "📋 Informe completo" --scrolltext --msgbox "$(echo -e "$all")" 25 80 ;;
      7)
        generate_report ;;
    esac
  done
}

# ------------------------------------------
# 🚀 Inicio del script
# ------------------------------------------
clear
echo "🧩 DriverCheck GUI v2.0"
detect_distro
echo "📦 Detección de distribución: $DISTRO"
install_deps
main_menu
