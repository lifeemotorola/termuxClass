#!/bin/bash
# ============================================================================
# TERMUX TOOLS MASTERCLASS - Complete Interactive Learning Platform
# ============================================================================
# Author: Emmanuel Suah
# File: Class.sh
# Description: A comprehensive interactive lesson on Termux tools
#              From absolute beginner to advanced level
# Usage: bash Class.sh
# ============================================================================

# ========================= COLOR DEFINITIONS ================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
RESET='\033[0m'
BG_BLUE='\033[44m'
BG_GREEN='\033[42m'
BG_RED='\033[41m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'

# ========================= GLOBAL VARIABLES =================================
SCORE=0
TOTAL_QUESTIONS=0
CURRENT_MODULE=0
TOTAL_MODULES=12
USER_NAME=""
PROGRESS_FILE="$HOME/.termux_lesson_progress"
LOG_FILE="$HOME/.termux_lesson_log"
LESSON_DIR="$HOME/termux_lesson_workspace"

# ========================= UTILITY FUNCTIONS ================================

clear_screen() {
    clear
}

press_continue() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${YELLOW}  Press [ENTER] to continue...${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -r
}

print_header() {
    local title="$1"
    local width=64
    local padding=$(( (width - ${#title} - 2) / 2 ))
    clear_screen
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${BG_BLUE}${WHITE}${BOLD}$(printf '%*s' $padding '')$title$(printf '%*s' $((width - padding - ${#title} - 2)) '')${RESET}${CYAN}║${RESET}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${CYAN}║${RESET}  ${MAGENTA}Author: Emmanuel Suah${RESET}$(printf '%*s' 39 '')${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${MAGENTA}Level: Beginner → Advanced${RESET}$(printf '%*s' 34 '')${CYAN}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_section() {
    local title="$1"
    echo ""
    echo -e "${GREEN}┌──────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${GREEN}│${RESET}  ${BOLD}${WHITE}📖 $title${RESET}"
    echo -e "${GREEN}└──────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

print_subsection() {
    local title="$1"
    echo ""
    echo -e "  ${YELLOW}▸ ${BOLD}$title${RESET}"
    echo -e "  ${YELLOW}$(printf '%.0s─' {1..58})${RESET}"
}

print_command() {
    local cmd="$1"
    echo -e "    ${BG_CYAN}${WHITE} \$ ${RESET} ${GREEN}$cmd${RESET}"
}

print_output() {
    local output="$1"
    echo -e "    ${WHITE}  ↳ $output${RESET}"
}

print_info() {
    local info="$1"
    echo -e "  ${BLUE}ℹ${RESET}  ${WHITE}$info${RESET}"
}

print_warning() {
    local warning="$1"
    echo -e "  ${YELLOW}⚠${RESET}  ${YELLOW}$warning${RESET}"
}

print_success() {
    local msg="$1"
    echo -e "  ${GREEN}✔${RESET}  ${GREEN}$msg${RESET}"
}

print_error() {
    local msg="$1"
    echo -e "  ${RED}✘${RESET}  ${RED}$msg${RESET}"
}

print_tip() {
    local tip="$1"
    echo -e "  ${MAGENTA}💡 TIP:${RESET} ${WHITE}$tip${RESET}"
}

print_note() {
    local note="$1"
    echo -e "  ${CYAN}📝 NOTE:${RESET} ${WHITE}$note${RESET}"
}

print_code_block() {
    echo -e "    ${WHITE}┌─────────────────────────────────────────────────────┐${RESET}"
    while IFS= read -r line; do
        printf "    ${WHITE}│${RESET} ${GREEN}%-51s${RESET} ${WHITE}│${RESET}\n" "$line"
    done
    echo -e "    ${WHITE}└─────────────────────────────────────────────────────┘${RESET}"
}

show_progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "  ${CYAN}Progress: [${RESET}"
    printf "${GREEN}%0.s█${RESET}" $(seq 1 $filled 2>/dev/null)
    printf "${WHITE}%0.s░${RESET}" $(seq 1 $empty 2>/dev/null)
    printf "${CYAN}] %d%% (%d/%d)${RESET}\n" "$percentage" "$current" "$total"
}

# ========================= QUIZ FUNCTIONS ===================================

ask_multiple_choice() {
    local question="$1"
    local option_a="$2"
    local option_b="$3"
    local option_c="$4"
    local option_d="$5"
    local correct="$6"
    local explanation="$7"

    TOTAL_QUESTIONS=$((TOTAL_QUESTIONS + 1))

    echo ""
    echo -e "  ${BG_MAGENTA}${WHITE}${BOLD} QUIZ QUESTION #$TOTAL_QUESTIONS ${RESET}"
    echo ""
    echo -e "  ${WHITE}${BOLD}$question${RESET}"
    echo ""
    echo -e "    ${CYAN}A)${RESET} $option_a"
    echo -e "    ${CYAN}B)${RESET} $option_b"
    echo -e "    ${CYAN}C)${RESET} $option_c"
    echo -e "    ${CYAN}D)${RESET} $option_d"
    echo ""

    local answer=""
    while [[ ! "$answer" =~ ^[AaBbCcDd]$ ]]; do
        echo -ne "  ${YELLOW}Your answer (A/B/C/D): ${RESET}"
        read -r answer
    done

    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')

    if [[ "$answer" == "$correct" ]]; then
        SCORE=$((SCORE + 1))
        echo ""
        print_success "CORRECT! 🎉"
    else
        echo ""
        print_error "INCORRECT! The correct answer is: $correct"
    fi

    if [[ -n "$explanation" ]]; then
        echo -e "  ${CYAN}📋 Explanation:${RESET} $explanation"
    fi
    echo ""
    echo -e "  ${WHITE}Current Score: $SCORE/$TOTAL_QUESTIONS${RESET}"
}

ask_true_false() {
    local question="$1"
    local correct="$2"
    local explanation="$3"

    TOTAL_QUESTIONS=$((TOTAL_QUESTIONS + 1))

    echo ""
    echo -e "  ${BG_MAGENTA}${WHITE}${BOLD} TRUE OR FALSE #$TOTAL_QUESTIONS ${RESET}"
    echo ""
    echo -e "  ${WHITE}${BOLD}$question${RESET}"
    echo ""

    local answer=""
    while [[ ! "$answer" =~ ^[TtFf]$ ]]; do
        echo -ne "  ${YELLOW}Your answer (T for True / F for False): ${RESET}"
        read -r answer
    done

    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')

    if [[ "$answer" == "$correct" ]]; then
        SCORE=$((SCORE + 1))
        echo ""
        print_success "CORRECT! 🎉"
    else
        echo ""
        print_error "INCORRECT! The correct answer is: $correct"
    fi

    if [[ -n "$explanation" ]]; then
        echo -e "  ${CYAN}📋 Explanation:${RESET} $explanation"
    fi
    echo ""
    echo -e "  ${WHITE}Current Score: $SCORE/$TOTAL_QUESTIONS${RESET}"
}

ask_fill_blank() {
    local question="$1"
    local correct="$2"
    local explanation="$3"

    TOTAL_QUESTIONS=$((TOTAL_QUESTIONS + 1))

    echo ""
    echo -e "  ${BG_MAGENTA}${WHITE}${BOLD} FILL IN THE BLANK #$TOTAL_QUESTIONS ${RESET}"
    echo ""
    echo -e "  ${WHITE}${BOLD}$question${RESET}"
    echo ""

    echo -ne "  ${YELLOW}Your answer: ${RESET}"
    read -r answer

    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]' | xargs)
    correct_lower=$(echo "$correct" | tr '[:upper:]' '[:lower:]' | xargs)

    if [[ "$answer" == "$correct_lower" ]]; then
        SCORE=$((SCORE + 1))
        echo ""
        print_success "CORRECT! 🎉"
    else
        echo ""
        print_error "INCORRECT! The correct answer is: $correct"
    fi

    if [[ -n "$explanation" ]]; then
        echo -e "  ${CYAN}📋 Explanation:${RESET} $explanation"
    fi
    echo ""
    echo -e "  ${WHITE}Current Score: $SCORE/$TOTAL_QUESTIONS${RESET}"
}

# ========================= TRY IT YOURSELF ==================================

try_it_yourself() {
    local description="$1"
    local hint="$2"

    echo ""
    echo -e "  ${BG_GREEN}${WHITE}${BOLD} 🔧 TRY IT YOURSELF ${RESET}"
    echo ""
    echo -e "  ${WHITE}$description${RESET}"
    if [[ -n "$hint" ]]; then
        echo -e "  ${MAGENTA}💡 Hint: $hint${RESET}"
    fi
    echo ""
    echo -e "  ${CYAN}Type your commands below. Type ${BOLD}'done'${RESET}${CYAN} when finished.${RESET}"
    echo -e "  ${CYAN}Type ${BOLD}'hint'${RESET}${CYAN} for a hint if available.${RESET}"
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    while true; do
        echo -ne "  ${GREEN}termux\$${RESET} "
        read -r user_cmd

        if [[ "$user_cmd" == "done" ]]; then
            print_success "Great job practicing! Let's continue."
            break
        elif [[ "$user_cmd" == "hint" ]]; then
            if [[ -n "$hint" ]]; then
                print_tip "$hint"
            else
                print_info "No additional hints available."
            fi
        elif [[ -n "$user_cmd" ]]; then
            # Execute in a subshell for safety
            echo -e "  ${WHITE}Output:${RESET}"
            (eval "$user_cmd" 2>&1) | while IFS= read -r line; do
                echo -e "    ${WHITE}$line${RESET}"
            done
        fi
    done
    echo ""
}

# ========================= EXERCISE FUNCTIONS ===============================

run_exercise() {
    local exercise_num="$1"
    local title="$2"
    local description="$3"
    local task="$4"
    local verification_cmd="$5"
    local expected="$6"

    echo ""
    echo -e "  ${BG_RED}${WHITE}${BOLD} 📝 EXERCISE #$exercise_num ${RESET}"
    echo -e "  ${BOLD}${WHITE}$title${RESET}"
    echo ""
    echo -e "  ${WHITE}Description: $description${RESET}"
    echo ""
    echo -e "  ${YELLOW}Task: $task${RESET}"
    echo ""
    echo -e "  ${CYAN}Complete the task, then type 'verify' to check your work.${RESET}"
    echo -e "  ${CYAN}Type 'skip' to skip this exercise.${RESET}"
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    while true; do
        echo -ne "  ${GREEN}exercise\$${RESET} "
        read -r user_input

        if [[ "$user_input" == "verify" ]]; then
            if [[ -n "$verification_cmd" ]]; then
                result=$(eval "$verification_cmd" 2>/dev/null)
                if [[ "$result" == *"$expected"* ]] || [[ -n "$result" ]]; then
                    print_success "Exercise completed successfully! 🎉"
                    SCORE=$((SCORE + 1))
                    TOTAL_QUESTIONS=$((TOTAL_QUESTIONS + 1))
                    break
                else
                    print_error "Not quite right. Try again or type 'skip'."
                fi
            else
                print_success "Exercise marked as attempted! 🎉"
                break
            fi
        elif [[ "$user_input" == "skip" ]]; then
            TOTAL_QUESTIONS=$((TOTAL_QUESTIONS + 1))
            print_warning "Exercise skipped. You can come back to it later."
            break
        elif [[ -n "$user_input" ]]; then
            (eval "$user_input" 2>&1) | while IFS= read -r line; do
                echo -e "    ${WHITE}$line${RESET}"
            done
        fi
    done
    echo ""
}

# ========================= SAVE/LOAD PROGRESS ==============================

save_progress() {
    echo "MODULE=$CURRENT_MODULE" > "$PROGRESS_FILE"
    echo "SCORE=$SCORE" >> "$PROGRESS_FILE"
    echo "TOTAL_QUESTIONS=$TOTAL_QUESTIONS" >> "$PROGRESS_FILE"
    echo "USER_NAME=$USER_NAME" >> "$PROGRESS_FILE"
    echo "TIMESTAMP=$(date)" >> "$PROGRESS_FILE"
}

load_progress() {
    if [[ -f "$PROGRESS_FILE" ]]; then
        source "$PROGRESS_FILE"
        return 0
    fi
    return 1
}

# ========================= SETUP WORKSPACE =================================

setup_workspace() {
    mkdir -p "$LESSON_DIR"
    cd "$LESSON_DIR" || exit 1
}

# ========================= WELCOME SCREEN ==================================

show_welcome() {
    clear_screen
    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║   ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗     ║
    ║   ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝     ║
    ║      ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝      ║
    ║      ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗      ║
    ║      ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗     ║
    ║      ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═╝     ║
    ║                                                              ║
    ║           ████████╗ ██████╗  ██████╗ ██╗     ███████╗        ║
    ║           ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝        ║
    ║              ██║   ██║   ██║██║   ██║██║     ███████╗        ║
    ║              ██║   ██║   ██║██║   ██║██║     ╚════██║        ║
    ║              ██║   ╚██████╔╝╚██████╔╝███████╗███████║        ║
    ║              ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝        ║
    ║                                                              ║
    ║          M A S T E R C L A S S                               ║
    ║                                                              ║
    ╠══════════════════════════════════════════════════════════════╣
    ║                                                              ║
    ║  📚 Complete Interactive Course                               ║
    ║  👤 Author: Emmanuel Suah                                    ║
    ║  📊 Level: Absolute Beginner → Advanced                      ║
    ║  📝 Includes: Lessons, Quizzes, Exercises & Practice         ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${RESET}"

    echo ""
    echo -ne "  ${YELLOW}Enter your name: ${RESET}"
    read -r USER_NAME

    if [[ -z "$USER_NAME" ]]; then
        USER_NAME="Student"
    fi

    echo ""
    echo -e "  ${GREEN}Welcome, ${BOLD}$USER_NAME${RESET}${GREEN}! 🎓${RESET}"
    echo ""

    if load_progress 2>/dev/null && [[ -n "$CURRENT_MODULE" ]] && [[ "$CURRENT_MODULE" -gt 0 ]]; then
        echo -e "  ${CYAN}Previous progress detected!${RESET}"
        echo -e "  ${WHITE}Last module: $CURRENT_MODULE | Score: $SCORE/$TOTAL_QUESTIONS${RESET}"
        echo -ne "  ${YELLOW}Resume from where you left off? (y/n): ${RESET}"
        read -r resume
        if [[ "$resume" != "y" && "$resume" != "Y" ]]; then
            SCORE=0
            TOTAL_QUESTIONS=0
            CURRENT_MODULE=0
        fi
    fi

    press_continue
}

# ========================= TABLE OF CONTENTS ================================

show_table_of_contents() {
    print_header "TABLE OF CONTENTS"

    echo -e "  ${WHITE}${BOLD}This course covers $TOTAL_MODULES comprehensive modules:${RESET}"
    echo ""
    echo -e "  ${CYAN}╔════╦════════════════════════════════════════════════════════╗${RESET}"
    echo -e "  ${CYAN}║${RESET} ${BOLD}##${RESET} ${CYAN}║${RESET} ${BOLD}Module Title${RESET}                                ${CYAN}║${RESET} ${BOLD}Level${RESET}     ${CYAN}║${RESET}"
    echo -e "  ${CYAN}╠════╬════════════════════════════════════════════════════════╣${RESET}"
    echo -e "  ${CYAN}║${RESET} 01 ${CYAN}║${RESET} Introduction to Termux & Setup             ${CYAN}║${RESET} ${GREEN}Beginner${RESET}  ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET} 02 ${CYAN}║${RESET} Package Management (pkg & apt)             ${CYAN}║${RESET} ${GREEN}Beginner${RESET}  ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET} 03 ${CYAN}║${RESET} File System Navigation & Management        ${CYAN}║${RESET} ${GREEN}Beginner${RESET}  ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET} 04 ${CYAN}║${RESET} Text Processing Tools                      ${CYAN}║${RESET} ${YELLOW}Intermed.${RESET} ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET} 05 ${CYAN}║${RESET} Networking Tools                           ${CYAN}║${RESET} ${YELLOW}Intermed.${RESET} ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET} 06 ${CYAN}║${RESET} Termux API & Device Integration            ${CYAN}║${RESET} ${YELLOW}Intermed.${RESET} ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET} 07 ${CYAN}║${RESET} Shell Scripting in Termux                  ${CYAN}║${RESET} ${YELLOW}Intermed.${RESET} ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET} 08 ${CYAN}║${RESET} Programming Languages & Development        ${CYAN}║${RESET} ${YELLOW}Intermed.${RESET} ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET} 09 ${CYAN}║${RESET} Security & Penetration Testing Tools       ${CYAN}║${RESET} ${RED}Advanced${RESET}  ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET} 10 ${CYAN}║${RESET} Git & Version Control                      ${CYAN}║${RESET} ${YELLOW}Intermed.${RESET} ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET} 11 ${CYAN}║${RESET} Advanced System Tools & Automation         ${CYAN}║${RESET} ${RED}Advanced${RESET}  ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET} 12 ${CYAN}║${RESET} Final Comprehensive Project & Assessment   ${CYAN}║${RESET} ${RED}Advanced${RESET}  ${CYAN}║${RESET}"
    echo -e "  ${CYAN}╚════╩════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    show_progress_bar "$CURRENT_MODULE" "$TOTAL_MODULES"
    echo ""
    echo -e "  ${WHITE}Enter a module number (1-12) to jump to it, or press ENTER${RESET}"
    echo -ne "  ${WHITE}to start from ${BOLD}Module $((CURRENT_MODULE + 1))${RESET}: "
    read -r module_choice

    if [[ "$module_choice" =~ ^[0-9]+$ ]] && [[ "$module_choice" -ge 1 ]] && [[ "$module_choice" -le 12 ]]; then
        CURRENT_MODULE=$((module_choice - 1))
    fi
}

# ============================================================================
# MODULE 1: INTRODUCTION TO TERMUX & SETUP
# ============================================================================

module_01() {
    CURRENT_MODULE=1
    save_progress

    print_header "MODULE 1: Introduction to Termux & Setup"

    print_section "1.1 What is Termux?"

    echo -e "  ${WHITE}Termux is a powerful ${BOLD}terminal emulator${RESET}${WHITE} and ${BOLD}Linux environment${RESET}"
    echo -e "  ${WHITE}application for Android. It brings the power of Linux to your${RESET}"
    echo -e "  ${WHITE}mobile device without requiring root access.${RESET}"
    echo ""
    echo -e "  ${WHITE}Key Features:${RESET}"
    echo -e "    ${GREEN}●${RESET} Full Linux command-line environment"
    echo -e "    ${GREEN}●${RESET} Package manager (pkg/apt) with 1000+ packages"
    echo -e "    ${GREEN}●${RESET} Access to programming languages (Python, Node.js, C, etc.)"
    echo -e "    ${GREEN}●${RESET} SSH client and server capabilities"
    echo -e "    ${GREEN}●${RESET} File system access and management"
    echo -e "    ${GREEN}●${RESET} Termux API for device hardware access"
    echo -e "    ${GREEN}●${RESET} No root required for most operations"

    press_continue

    print_section "1.2 Termux Directory Structure"

    echo -e "  ${WHITE}Termux uses a unique directory structure:${RESET}"
    echo ""
    echo -e "    ${CYAN}/data/data/com.termux/files/${RESET}"
    echo -e "    ${WHITE}├── ${GREEN}home/${RESET}          ${WHITE}← Your home directory (\$HOME)${RESET}"
    echo -e "    ${WHITE}├── ${GREEN}usr/${RESET}           ${WHITE}← System files and packages${RESET}"
    echo -e "    ${WHITE}│   ├── ${YELLOW}bin/${RESET}       ${WHITE}← Executable programs${RESET}"
    echo -e "    ${WHITE}│   ├── ${YELLOW}etc/${RESET}       ${WHITE}← Configuration files${RESET}"
    echo -e "    ${WHITE}│   ├── ${YELLOW}lib/${RESET}       ${WHITE}← Library files${RESET}"
    echo -e "    ${WHITE}│   ├── ${YELLOW}share/${RESET}     ${WHITE}← Shared resources${RESET}"
    echo -e "    ${WHITE}│   ├── ${YELLOW}var/${RESET}       ${WHITE}← Variable data${RESET}"
    echo -e "    ${WHITE}│   └── ${YELLOW}tmp/${RESET}       ${WHITE}← Temporary files${RESET}"
    echo -e "    ${WHITE}└── ${GREEN}usr/etc/${RESET}      ${WHITE}← Additional config${RESET}"
    echo ""
    print_note "The PREFIX variable points to /data/data/com.termux/files/usr"

    press_continue

    print_section "1.3 Essential First Commands"

    print_subsection "Updating Termux"
    echo ""
    print_command "pkg update && pkg upgrade -y"
    print_info "Always run this first! Updates package lists and upgrades installed packages."
    echo ""

    print_subsection "Checking Your Environment"
    echo ""
    print_command "whoami"
    print_output "Returns your Termux username"
    echo ""
    print_command "pwd"
    print_output "Print Working Directory - shows where you are"
    echo ""
    print_command "echo \$HOME"
    print_output "/data/data/com.termux/files/home"
    echo ""
    print_command "echo \$PREFIX"
    print_output "/data/data/com.termux/files/usr"
    echo ""
    print_command "echo \$PATH"
    print_output "Shows all directories where commands are searched"
    echo ""
    print_command "uname -a"
    print_output "Shows system information (kernel, architecture, etc.)"

    press_continue

    print_section "1.4 Termux Keyboard Shortcuts"

    echo -e "  ${WHITE}Essential keyboard shortcuts:${RESET}"
    echo ""
    echo -e "    ${CYAN}Volume Down + C${RESET}   → Ctrl+C (interrupt/cancel)"
    echo -e "    ${CYAN}Volume Down + D${RESET}   → Ctrl+D (end of input/logout)"
    echo -e "    ${CYAN}Volume Down + L${RESET}   → Ctrl+L (clear screen)"
    echo -e "    ${CYAN}Volume Down + Z${RESET}   → Ctrl+Z (suspend process)"
    echo -e "    ${CYAN}Volume Down + E${RESET}   → Escape key"
    echo -e "    ${CYAN}Volume Down + T${RESET}   → Tab key (auto-complete)"
    echo -e "    ${CYAN}Volume Down + W${RESET}   → Arrow Up (previous command)"
    echo -e "    ${CYAN}Volume Down + S${RESET}   → Arrow Down (next command)"
    echo -e "    ${CYAN}Volume Down + A${RESET}   → Arrow Left"
    echo -e "    ${CYAN}Volume Down + D${RESET}   → Arrow Right"
    echo ""
    print_tip "Use the Volume Down key as a modifier for Ctrl and other keys!"

    press_continue

    print_section "1.5 Configuring Termux"

    print_subsection "Setting Up Storage Access"
    echo ""
    print_command "termux-setup-storage"
    print_info "This grants Termux access to your phone's internal storage."
    print_info "Creates symlinks in ~/storage/ pointing to common directories."
    echo ""

    print_subsection "Customizing the Terminal"
    echo ""
    print_command "mkdir -p ~/.termux"
    print_command "nano ~/.termux/termux.properties"
    echo ""
    echo -e "  ${WHITE}Common properties you can set:${RESET}" | print_code_block << 'EOF'
# Example termux.properties
extra-keys = [['ESC','/','-','HOME','UP','END'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT']]
bell-character = vibrate
use-black-ui = true
EOF
    echo ""
    print_command "termux-reload-settings"
    print_info "Apply changes after editing termux.properties"

    press_continue

    # TRY IT YOURSELF
    try_it_yourself \
        "Try these commands to explore your Termux environment:
    1. Run 'whoami' to see your username
    2. Run 'pwd' to see your current directory
    3. Run 'echo \$PREFIX' to see the prefix path
    4. Run 'uname -a' to see system information
    5. Run 'ls' to list files in current directory" \
        "Type each command one at a time and observe the output"

    press_continue

    # QUIZ FOR MODULE 1
    print_section "Module 1 Quiz"

    ask_multiple_choice \
        "What is the home directory path in Termux?" \
        "/home/user" \
        "/data/data/com.termux/files/home" \
        "/root" \
        "/usr/home" \
        "B" \
        "Termux stores user data in /data/data/com.termux/files/home"

    press_continue

    ask_true_false \
        "Termux requires root access to function." \
        "F" \
        "Termux works without root by using its own Linux environment within the app's data directory."

    press_continue

    ask_multiple_choice \
        "Which key combination acts as Ctrl+C in Termux?" \
        "Volume Up + C" \
        "Volume Down + C" \
        "Power + C" \
        "Home + C" \
        "B" \
        "Volume Down serves as the Ctrl modifier in Termux."

    press_continue

    ask_fill_blank \
        "The command to update and upgrade packages is: pkg ________ && pkg upgrade" \
        "update" \
        "pkg update refreshes the package index, pkg upgrade installs newer versions."

    press_continue

    ask_multiple_choice \
        "What command gives Termux access to phone storage?" \
        "termux-access-storage" \
        "termux-storage-setup" \
        "termux-setup-storage" \
        "storage-access" \
        "C" \
        "termux-setup-storage creates symlinks to common storage directories."

    press_continue

    # EXERCISE
    print_section "Module 1 Exercises"

    run_exercise 1 \
        "Create Your First File" \
        "Use the echo command to create a file with your name in it." \
        "Create a file called 'myname.txt' in the lesson workspace containing your name." \
        "cat $LESSON_DIR/myname.txt 2>/dev/null" \
        ""

    press_continue
    print_success "Module 1 Complete! 🎉"
    show_progress_bar 1 $TOTAL_MODULES
    press_continue
}

# ============================================================================
# MODULE 2: PACKAGE MANAGEMENT
# ============================================================================

module_02() {
    CURRENT_MODULE=2
    save_progress

    print_header "MODULE 2: Package Management (pkg & apt)"

    print_section "2.1 Understanding Package Management"

    echo -e "  ${WHITE}Termux uses ${BOLD}pkg${RESET}${WHITE} (a wrapper around ${BOLD}apt${RESET}${WHITE}) to manage software${RESET}"
    echo -e "  ${WHITE}packages. Think of it as an app store for command-line tools.${RESET}"
    echo ""
    echo -e "  ${WHITE}Package Management Hierarchy:${RESET}"
    echo ""
    echo -e "    ${CYAN}pkg${RESET}  ←  User-friendly wrapper (recommended)"
    echo -e "     ${WHITE}↓${RESET}"
    echo -e "    ${CYAN}apt${RESET}  ←  Advanced Package Tool (Debian-based)"
    echo -e "     ${WHITE}↓${RESET}"
    echo -e "    ${CYAN}dpkg${RESET} ←  Low-level package manager"

    press_continue

    print_section "2.2 Essential pkg Commands"

    print_subsection "Updating Package Lists"
    print_command "pkg update"
    print_info "Downloads the latest list of available packages"
    echo ""

    print_subsection "Upgrading Installed Packages"
    print_command "pkg upgrade"
    print_info "Updates all installed packages to their latest versions"
    echo ""

    print_subsection "Installing Packages"
    print_command "pkg install <package-name>"
    print_command "pkg install python nodejs git -y"
    print_info "The -y flag auto-confirms installation prompts"
    echo ""

    print_subsection "Removing Packages"
    print_command "pkg uninstall <package-name>"
    print_command "pkg uninstall --purge <package-name>"
    print_info "--purge also removes configuration files"
    echo ""

    print_subsection "Searching for Packages"
    print_command "pkg search <keyword>"
    print_command "pkg search python"
    print_info "Searches package names and descriptions"
    echo ""

    print_subsection "Listing Packages"
    print_command "pkg list-all"
    print_info "Shows all available packages"
    echo ""
    print_command "pkg list-installed"
    print_info "Shows only installed packages"
    echo ""

    print_subsection "Package Information"
    print_command "pkg show <package-name>"
    print_info "Displays detailed information about a package"

    press_continue

    print_section "2.3 Advanced apt Commands"

    echo -e "  ${WHITE}While pkg is recommended, apt offers additional features:${RESET}"
    echo ""
    print_command "apt list --upgradable"
    print_info "Shows packages with available updates"
    echo ""
    print_command "apt autoremove"
    print_info "Removes packages that were installed as dependencies but no longer needed"
    echo ""
    print_command "apt clean"
    print_info "Removes cached .deb files to free space"
    echo ""
    print_command "apt depends <package>"
    print_info "Shows dependencies of a package"
    echo ""
    print_command "apt rdepends <package>"
    print_info "Shows which packages depend on this package (reverse dependencies)"
    echo ""
    print_command "dpkg -L <package>"
    print_info "Lists all files installed by a package"
    echo ""
    print_command "dpkg -S /path/to/file"
    print_info "Finds which package owns a specific file"

    press_continue

    print_section "2.4 Must-Have Packages for Termux"

    echo -e "  ${WHITE}Here are essential packages organized by category:${RESET}"
    echo ""
    echo -e "  ${BOLD}${CYAN}📦 Core Utilities:${RESET}"
    echo -e "    ${GREEN}coreutils${RESET}    - GNU core utilities (ls, cp, mv, etc.)"
    echo -e "    ${GREEN}findutils${RESET}    - find, xargs, locate commands"
    echo -e "    ${GREEN}grep${RESET}         - Pattern searching"
    echo -e "    ${GREEN}sed${RESET}          - Stream editor"
    echo -e "    ${GREEN}gawk${RESET}         - Pattern processing language"
    echo -e "    ${GREEN}tar${RESET}          - Archive utility"
    echo -e "    ${GREEN}zip/unzip${RESET}    - ZIP compression"
    echo ""
    echo -e "  ${BOLD}${CYAN}📝 Text Editors:${RESET}"
    echo -e "    ${GREEN}nano${RESET}         - Simple text editor (beginner-friendly)"
    echo -e "    ${GREEN}vim${RESET}          - Powerful text editor (learning curve)"
    echo -e "    ${GREEN}micro${RESET}        - Modern, intuitive editor"
    echo -e "    ${GREEN}emacs${RESET}        - Extensible text editor"
    echo ""
    echo -e "  ${BOLD}${CYAN}🌐 Networking:${RESET}"
    echo -e "    ${GREEN}curl${RESET}         - Data transfer tool"
    echo -e "    ${GREEN}wget${RESET}         - File downloader"
    echo -e "    ${GREEN}openssh${RESET}      - SSH client and server"
    echo -e "    ${GREEN}nmap${RESET}         - Network scanner"
    echo -e "    ${GREEN}net-tools${RESET}    - Network utilities"
    echo ""
    echo -e "  ${BOLD}${CYAN}💻 Development:${RESET}"
    echo -e "    ${GREEN}python${RESET}       - Python programming language"
    echo -e "    ${GREEN}nodejs${RESET}       - JavaScript runtime"
    echo -e "    ${GREEN}clang${RESET}        - C/C++ compiler"
    echo -e "    ${GREEN}ruby${RESET}         - Ruby programming language"
    echo -e "    ${GREEN}git${RESET}          - Version control"
    echo -e "    ${GREEN}make${RESET}         - Build automation"

    press_continue

    print_section "2.5 Managing Repositories"

    echo -e "  ${WHITE}Termux supports additional package repositories:${RESET}"
    echo ""
    print_subsection "Default Repositories"
    print_command "cat \$PREFIX/etc/apt/sources.list"
    echo ""

    print_subsection "Adding Termux Community Repos"
    print_command "pkg install root-repo"
    print_info "Adds packages that require root access"
    echo ""
    print_command "pkg install x11-repo"
    print_info "Adds graphical/X11 related packages"
    echo ""
    print_command "pkg install tur-repo"
    print_info "Adds Termux User Repository for extra packages"
    echo ""

    print_subsection "Changing Mirrors"
    print_command "termux-change-repo"
    print_info "Interactive tool to change package download mirrors"
    print_tip "If downloads are slow, try changing to a closer mirror!"

    press_continue

    # TRY IT YOURSELF
    try_it_yourself \
        "Practice package management:
    1. Run 'pkg list-installed' to see what's installed
    2. Run 'pkg search editor' to find text editors
    3. Run 'pkg show python' to see Python package info
    4. Try installing a package: 'pkg install tree -y'
    5. Run 'tree --version' to verify installation" \
        "Use 'pkg install <name> -y' to skip confirmation prompts"

    press_continue

    # QUIZ
    print_section "Module 2 Quiz"

    ask_multiple_choice \
        "Which command installs a package without asking for confirmation?" \
        "pkg install python --force" \
        "pkg install python -y" \
        "pkg install python --yes" \
        "pkg install python --auto" \
        "B" \
        "The -y flag automatically answers yes to all prompts."

    press_continue

    ask_multiple_choice \
        "What does 'pkg search network' do?" \
        "Installs all network tools" \
        "Shows network status" \
        "Searches for packages matching 'network'" \
        "Removes network packages" \
        "C" \
        "pkg search looks for packages whose name or description contains the search term."

    press_continue

    ask_fill_blank \
        "To remove unused dependency packages, use: apt __________" \
        "autoremove" \
        "apt autoremove cleans up packages that were installed as dependencies but are no longer needed."

    press_continue

    ask_true_false \
        "pkg is a wrapper around apt in Termux." \
        "T" \
        "pkg provides a user-friendly interface that calls apt commands underneath."

    press_continue

    ask_multiple_choice \
        "Which command changes the package download mirror?" \
        "pkg change-mirror" \
        "termux-change-repo" \
        "apt mirror-select" \
        "pkg set-mirror" \
        "B" \
        "termux-change-repo is the official interactive tool for changing mirrors."

    press_continue

    # EXERCISE
    print_section "Module 2 Exercises"

    run_exercise 2 \
        "Install and Verify a Package" \
        "Install the 'tree' package and verify it works." \
        "Install tree using pkg, then create a directory structure and display it with tree." \
        "which tree 2>/dev/null" \
        "tree"

    press_continue

    run_exercise 3 \
        "Package Investigation" \
        "Find out how many packages are currently installed on your system." \
        "Use pkg list-installed and pipe it to wc -l to count lines." \
        "" \
        ""

    press_continue
    print_success "Module 2 Complete! 🎉"
    show_progress_bar 2 $TOTAL_MODULES
    press_continue
}

# ============================================================================
# MODULE 3: FILE SYSTEM NAVIGATION & MANAGEMENT
# ============================================================================

module_03() {
    CURRENT_MODULE=3
    save_progress

    print_header "MODULE 3: File System Navigation & Management"

    print_section "3.1 Navigation Commands"

    print_subsection "cd - Change Directory"
    print_command "cd /path/to/directory"
    print_command "cd ~             # Go to home directory"
    print_command "cd ..            # Go up one level"
    print_command "cd ../..         # Go up two levels"
    print_command "cd -             # Go to previous directory"
    print_command "cd /             # Go to root directory"
    echo ""

    print_subsection "ls - List Files"
    print_command "ls               # Basic listing"
    print_command "ls -l            # Long format (permissions, size, date)"
    print_command "ls -la           # Include hidden files"
    print_command "ls -lh           # Human-readable sizes"
    print_command "ls -lt           # Sort by time (newest first)"
    print_command "ls -lS           # Sort by size (largest first)"
    print_command "ls -R            # Recursive listing"
    print_command "ls -1            # One file per line"
    echo ""

    print_subsection "pwd - Print Working Directory"
    print_command "pwd              # Show current full path"

    press_continue

    print_section "3.2 File Operations"

    print_subsection "Creating Files and Directories"
    print_command "touch file.txt                   # Create empty file"
    print_command "mkdir new_directory               # Create directory"
    print_command "mkdir -p path/to/nested/dir       # Create nested dirs"
    print_command "echo 'Hello' > file.txt           # Create with content"
    print_command "echo 'More text' >> file.txt      # Append to file"
    echo ""

    print_subsection "Copying"
    print_command "cp source.txt destination.txt     # Copy file"
    print_command "cp -r source_dir/ dest_dir/       # Copy directory"
    print_command "cp -v file1 file2                 # Verbose copy"
    print_command "cp -i file1 file2                 # Interactive (ask before overwrite)"
    echo ""

    print_subsection "Moving and Renaming"
    print_command "mv old_name.txt new_name.txt      # Rename file"
    print_command "mv file.txt /path/to/dest/        # Move file"
    print_command "mv -i source dest                 # Interactive move"
    echo ""

    print_subsection "Removing Files"
    print_command "rm file.txt                       # Remove file"
    print_command "rm -r directory/                  # Remove directory"
    print_command "rm -rf directory/                 # Force remove (CAREFUL!)"
    print_command "rm -i file.txt                    # Interactive remove"
    echo ""
    print_warning "rm -rf is DANGEROUS! Always double-check the path before using it!"

    press_continue

    print_section "3.3 File Viewing Commands"

    print_subsection "Viewing File Contents"
    print_command "cat file.txt           # Display entire file"
    print_command "head file.txt          # Show first 10 lines"
    print_command "head -n 20 file.txt    # Show first 20 lines"
    print_command "tail file.txt          # Show last 10 lines"
    print_command "tail -n 20 file.txt    # Show last 20 lines"
    print_command "tail -f logfile.txt    # Follow file changes (live)"
    print_command "less file.txt          # Paginated viewer (q to quit)"
    print_command "more file.txt          # Simple paginated viewer"
    print_command "wc file.txt            # Word, line, character count"
    print_command "wc -l file.txt         # Count lines only"

    press_continue

    print_section "3.4 File Search & Find"

    print_subsection "find - Search for Files"
    print_command "find . -name '*.txt'              # Find by name"
    print_command "find . -type f                    # Find files only"
    print_command "find . -type d                    # Find directories only"
    print_command "find . -size +1M                  # Files larger than 1MB"
    print_command "find . -mtime -7                  # Modified in last 7 days"
    print_command "find . -name '*.log' -delete      # Find and delete"
    print_command "find . -name '*.py' -exec wc -l {} \\;"
    print_info "Find Python files and count lines in each"
    echo ""

    print_subsection "which & whereis - Locate Commands"
    print_command "which python           # Find command location"
    print_command "whereis python         # Find binary, source, man pages"
    echo ""

    print_subsection "locate - Fast File Search"
    print_command "pkg install mlocate"
    print_command "updatedb               # Update file database"
    print_command "locate filename        # Fast search using database"

    press_continue

    print_section "3.5 File Permissions"

    echo -e "  ${WHITE}Linux file permissions consist of three groups:${RESET}"
    echo ""
    echo -e "    ${CYAN}Owner (u)${RESET}  |  ${GREEN}Group (g)${RESET}  |  ${YELLOW}Others (o)${RESET}"
    echo -e "    ${CYAN}rwx${RESET}        |  ${GREEN}rwx${RESET}        |  ${YELLOW}rwx${RESET}"
    echo ""
    echo -e "  ${WHITE}Where:${RESET}"
    echo -e "    ${GREEN}r${RESET} = read (4)     ${GREEN}w${RESET} = write (2)     ${GREEN}x${RESET} = execute (1)"
    echo ""
    echo -e "  ${WHITE}Examples:${RESET}"
    echo -e "    ${CYAN}755${RESET} = rwxr-xr-x  (Owner: full, Group/Others: read+execute)"
    echo -e "    ${CYAN}644${RESET} = rw-r--r--  (Owner: read+write, Group/Others: read only)"
    echo -e "    ${CYAN}700${RESET} = rwx------  (Owner: full, Group/Others: no access)"
    echo ""

    print_command "chmod 755 script.sh        # Set permissions numerically"
    print_command "chmod +x script.sh         # Add execute permission"
    print_command "chmod u+w file.txt         # Add write for owner"
    print_command "chmod go-r file.txt        # Remove read from group & others"
    print_command "chmod -R 755 directory/    # Recursive permission change"

    press_continue

    print_section "3.6 Disk Usage & Storage"

    print_command "df -h                      # Show disk space usage"
    print_command "du -sh *                   # Size of files/dirs in current dir"
    print_command "du -sh ~/                  # Total size of home directory"
    print_command "du -sh * | sort -rh        # Sort by size (largest first)"
    print_command "du -ah . | sort -rh | head -20"
    print_info "Find 20 largest files in current directory"

    press_continue

    # TRY IT YOURSELF
    setup_workspace
    try_it_yourself \
        "Practice file operations:
    1. Create a directory called 'practice' with: mkdir practice
    2. Navigate into it: cd practice
    3. Create 3 files: touch file1.txt file2.txt file3.txt
    4. Write to file1: echo 'Hello World' > file1.txt
    5. Copy file1 to file4: cp file1.txt file4.txt
    6. List all files with details: ls -la
    7. Check file content: cat file1.txt
    8. Find all .txt files: find . -name '*.txt'" \
        "Remember: mkdir creates directories, touch creates empty files"

    press_continue

    # QUIZ
    print_section "Module 3 Quiz"

    ask_multiple_choice \
        "What does 'ls -lah' display?" \
        "Only hidden files" \
        "Long format, all files, human-readable sizes" \
        "Files sorted alphabetically" \
        "Only large files" \
        "B" \
        "-l is long format, -a includes hidden files, -h shows human-readable sizes."

    press_continue

    ask_fill_blank \
        "To create nested directories in one command, use: mkdir ____ path/to/dir" \
        "-p" \
        "The -p flag creates parent directories as needed."

    press_continue

    ask_multiple_choice \
        "What permission number represents 'read + write + execute'?" \
        "5" \
        "6" \
        "7" \
        "8" \
        "C" \
        "r(4) + w(2) + x(1) = 7"

    press_continue

    ask_true_false \
        "The command 'cd -' takes you to the root directory." \
        "F" \
        "'cd -' takes you to the previous directory you were in. 'cd /' goes to root."

    press_continue

    ask_multiple_choice \
        "Which command shows disk usage in human-readable format?" \
        "disk -h" \
        "du -sh" \
        "df -h" \
        "Both B and C" \
        "D" \
        "du shows directory sizes, df shows filesystem disk space. Both support -h."

    press_continue

    # EXERCISES
    print_section "Module 3 Exercises"

    setup_workspace

    run_exercise 4 \
        "Directory Structure Challenge" \
        "Create the following directory structure:
        project/
        ├── src/
        │   ├── main.py
        │   └── utils.py
        ├── docs/
        │   └── readme.txt
        └── tests/" \
        "Use mkdir -p and touch to create this structure." \
        "test -d $LESSON_DIR/project/src && test -d $LESSON_DIR/project/docs && test -d $LESSON_DIR/project/tests && echo 'exists'" \
        "exists"

    press_continue

    run_exercise 5 \
        "File Permission Challenge" \
        "Create a script file called 'hello.sh', write 'echo Hello' in it, and make it executable." \
        "Use echo to write to file, then chmod to make it executable." \
        "test -x $LESSON_DIR/hello.sh 2>/dev/null && echo 'executable'" \
        "executable"

    press_continue
    print_success "Module 3 Complete! 🎉"
    show_progress_bar 3 $TOTAL_MODULES
    press_continue
}

# ============================================================================
# MODULE 4: TEXT PROCESSING TOOLS
# ============================================================================

module_04() {
    CURRENT_MODULE=4
    save_progress

    print_header "MODULE 4: Text Processing Tools"

    print_section "4.1 grep - Pattern Searching"

    echo -e "  ${WHITE}grep (Global Regular Expression Print) searches for patterns${RESET}"
    echo -e "  ${WHITE}in files or input streams. It's one of the most powerful${RESET}"
    echo -e "  ${WHITE}Unix tools.${RESET}"
    echo ""

    print_subsection "Basic Usage"
    print_command "grep 'pattern' file.txt           # Search in file"
    print_command "grep -i 'pattern' file.txt        # Case insensitive"
    print_command "grep -n 'pattern' file.txt        # Show line numbers"
    print_command "grep -c 'pattern' file.txt        # Count matches"
    print_command "grep -r 'pattern' directory/      # Recursive search"
    print_command "grep -v 'pattern' file.txt        # Invert (show non-matches)"
    print_command "grep -l 'pattern' *.txt           # Show only filenames"
    print_command "grep -w 'word' file.txt           # Match whole words only"
    echo ""

    print_subsection "Regular Expressions with grep"
    print_command "grep '^Start' file.txt            # Lines starting with 'Start'"
    print_command "grep 'end\$' file.txt              # Lines ending with 'end'"
    print_command "grep '[0-9]' file.txt             # Lines containing digits"
    print_command "grep -E '[0-9]{3}' file.txt       # Three consecutive digits"
    print_command "grep -E 'cat|dog' file.txt        # Match 'cat' OR 'dog'"
    echo ""

    print_subsection "Piping with grep"
    print_command "ps aux | grep python              # Find python processes"
    print_command "cat /etc/passwd | grep -c ':'"
    print_command "history | grep 'install'"
    print_command "ls -la | grep '.txt'"

    press_continue

    print_section "4.2 sed - Stream Editor"

    echo -e "  ${WHITE}sed performs text transformations on files or input streams.${RESET}"
    echo ""

    print_subsection "Substitution (Find & Replace)"
    print_command "sed 's/old/new/' file.txt              # Replace first occurrence"
    print_command "sed 's/old/new/g' file.txt             # Replace all occurrences"
    print_command "sed -i 's/old/new/g' file.txt          # Edit file in-place"
    print_command "sed 's/old/new/gi' file.txt            # Case insensitive"
    echo ""

    print_subsection "Line Operations"
    print_command "sed -n '5p' file.txt                   # Print line 5"
    print_command "sed -n '5,10p' file.txt                # Print lines 5-10"
    print_command "sed '3d' file.txt                      # Delete line 3"
    print_command "sed '/pattern/d' file.txt              # Delete matching lines"
    print_command "sed '2i\\New Line' file.txt            # Insert before line 2"
    print_command "sed '2a\\New Line' file.txt            # Append after line 2"
    echo ""

    print_subsection "Advanced sed"
    print_command "sed '/^$/d' file.txt                   # Remove empty lines"
    print_command "sed 's/^[ \\t]*//' file.txt            # Remove leading whitespace"
    print_command "sed -n '/start/,/end/p' file.txt       # Print between patterns"
    print_command "sed 's/.*/\\U&/' file.txt               # Convert to uppercase"
    print_command "sed 's/.*/\\L&/' file.txt               # Convert to lowercase"

    press_continue

    print_section "4.3 awk - Pattern Processing"

    echo -e "  ${WHITE}awk is a powerful programming language for text processing.${RESET}"
    echo ""

    print_subsection "Basic Usage"
    print_command "awk '{print}' file.txt                 # Print all lines"
    print_command "awk '{print \$1}' file.txt             # Print first column"
    print_command "awk '{print \$1, \$3}' file.txt        # Print columns 1 and 3"
    print_command "awk '{print NR, \$0}' file.txt         # Print with line numbers"
    print_command "awk -F':' '{print \$1}' /etc/passwd    # Custom delimiter"
    echo ""

    print_subsection "Filtering"
    print_command "awk '/pattern/' file.txt               # Lines matching pattern"
    print_command "awk '\$3 > 100' file.txt               # Where column 3 > 100"
    print_command "awk 'NR >= 5 && NR <= 10' file.txt     # Lines 5 through 10"
    print_command "awk 'NF > 3' file.txt                  # Lines with >3 fields"
    echo ""

    print_subsection "Calculations"
    print_command "awk '{sum += \$1} END {print sum}' file.txt"
    print_info "Sum all values in column 1"
    echo ""
    print_command "awk '{sum += \$1} END {print sum/NR}' file.txt"
    print_info "Calculate average of column 1"
    echo ""
    print_command "awk 'BEGIN {print \"Name\", \"Score\"} {print \$1, \$2}' file.txt"
    print_info "Add header before processing"

    press_continue

    print_section "4.4 sort, uniq, cut, tr"

    print_subsection "sort - Sort Lines"
    print_command "sort file.txt                     # Alphabetical sort"
    print_command "sort -n file.txt                  # Numerical sort"
    print_command "sort -r file.txt                  # Reverse sort"
    print_command "sort -k2 file.txt                 # Sort by column 2"
    print_command "sort -t':' -k3 -n file.txt        # Sort by field 3, numeric"
    print_command "sort -u file.txt                  # Sort and remove duplicates"
    echo ""

    print_subsection "uniq - Report/Remove Duplicates"
    print_command "sort file.txt | uniq              # Remove duplicates (sort first!)"
    print_command "sort file.txt | uniq -c           # Count occurrences"
    print_command "sort file.txt | uniq -d           # Show only duplicates"
    print_command "sort file.txt | uniq -u           # Show only unique lines"
    echo ""

    print_subsection "cut - Extract Columns"
    print_command "cut -d':' -f1 /etc/passwd         # Field 1, delimited by :"
    print_command "cut -c1-10 file.txt               # Characters 1-10"
    print_command "cut -d',' -f2,4 data.csv          # CSV fields 2 and 4"
    echo ""

    print_subsection "tr - Translate Characters"
    print_command "echo 'hello' | tr 'a-z' 'A-Z'    # To uppercase"
    print_command "echo 'HELLO' | tr 'A-Z' 'a-z'    # To lowercase"
    print_command "echo 'hello   world' | tr -s ' '  # Squeeze spaces"
    print_command "echo 'h3ll0' | tr -d '0-9'        # Delete digits"

    press_continue

    print_section "4.5 diff, comm, paste"

    print_subsection "diff - Compare Files"
    print_command "diff file1.txt file2.txt          # Show differences"
    print_command "diff -u file1.txt file2.txt       # Unified format"
    print_command "diff -y file1.txt file2.txt       # Side by side"
    print_command "diff -r dir1/ dir2/               # Compare directories"
    echo ""

    print_subsection "comm - Compare Sorted Files"
    print_command "comm file1.txt file2.txt          # 3-column comparison"
    print_command "comm -12 file1.txt file2.txt      # Lines common to both"
    print_command "comm -23 file1.txt file2.txt      # Lines only in file1"
    echo ""

    print_subsection "paste - Merge Files"
    print_command "paste file1.txt file2.txt         # Merge side by side"
    print_command "paste -d',' file1.txt file2.txt   # Custom delimiter"

    press_continue

    # TRY IT YOURSELF
    setup_workspace

    # Create sample data files
    cat > "$LESSON_DIR/sample_data.txt" << 'EOF'
John Smith 85 Engineering
Jane Doe 92 Science
Bob Wilson 78 Engineering
Alice Brown 95 Mathematics
Charlie Davis 88 Science
Eve Johnson 91 Engineering
Frank Miller 76 Mathematics
Grace Lee 89 Science
EOF

    cat > "$LESSON_DIR/log_sample.txt" << 'EOF'
2024-01-15 INFO Server started
2024-01-15 ERROR Connection failed
2024-01-15 INFO User logged in
2024-01-16 WARNING Disk space low
2024-01-16 ERROR Database timeout
2024-01-16 INFO Backup completed
2024-01-17 ERROR Memory overflow
2024-01-17 INFO Service restarted
EOF

    echo ""
    print_info "Sample files created in $LESSON_DIR"
    echo ""

    try_it_yourself \
        "Practice text processing with the sample files:
    1. Find all 'ERROR' entries: grep 'ERROR' log_sample.txt
    2. Count ERROR entries: grep -c 'ERROR' log_sample.txt
    3. Show Engineering students: awk '\$4==\"Engineering\"' sample_data.txt
    4. Sort students by score: sort -k3 -n sample_data.txt
    5. Get average score: awk '{sum+=\$3} END {print sum/NR}' sample_data.txt
    6. Replace 'ERROR' with 'CRITICAL': sed 's/ERROR/CRITICAL/g' log_sample.txt
    7. Extract names only: awk '{print \$1, \$2}' sample_data.txt" \
        "Use cd $LESSON_DIR first to access the sample files"

    press_continue

    # QUIZ
    print_section "Module 4 Quiz"

    ask_multiple_choice \
        "What does 'grep -i' do?" \
        "Show line numbers" \
        "Invert matches" \
        "Case insensitive search" \
        "Interactive mode" \
        "C" \
        "-i makes grep ignore case when matching. -n shows line numbers, -v inverts."

    press_continue

    ask_fill_blank \
        "To replace ALL occurrences in sed, use the ____ flag: sed 's/old/new/____'" \
        "g" \
        "The 'g' flag means global - replace all occurrences on each line, not just the first."

    press_continue

    ask_multiple_choice \
        "In awk, what does \$0 represent?" \
        "The first field" \
        "The last field" \
        "The entire line" \
        "The line number" \
        "C" \
        "\$0 is the entire line, \$1 is the first field, NR is the line number."

    press_continue

    ask_multiple_choice \
        "To count duplicate lines, which combination do you use?" \
        "sort | uniq -c" \
        "uniq -c" \
        "grep -c" \
        "wc -l" \
        "A" \
        "uniq requires sorted input, so you must sort first, then use uniq -c to count."

    press_continue

    ask_true_false \
        "The sed -i flag modifies the original file directly." \
        "T" \
        "The -i flag means 'in-place' editing - it changes the file directly without creating output."

    press_continue

    # EXERCISES
    print_section "Module 4 Exercises"

    run_exercise 6 \
        "Log Analysis" \
        "Using the log_sample.txt file, extract only the dates of ERROR entries and save to errors.txt" \
        "Use grep and awk together: grep 'ERROR' log_sample.txt | awk '{print \$1}' > errors.txt" \
        "cat $LESSON_DIR/errors.txt 2>/dev/null | wc -l" \
        ""

    press_continue

    run_exercise 7 \
        "Data Processing Pipeline" \
        "From sample_data.txt, find students with scores above 85, sort by score (descending), and show only names and scores." \
        "Combine awk filtering, sort, and awk formatting in a pipeline." \
        "" \
        ""

    press_continue
    print_success "Module 4 Complete! 🎉"
    show_progress_bar 4 $TOTAL_MODULES
    press_continue
}

# ============================================================================
# MODULE 5: NETWORKING TOOLS
# ============================================================================

module_05() {
    CURRENT_MODULE=5
    save_progress

    print_header "MODULE 5: Networking Tools"

    print_section "5.1 curl - Data Transfer"

    echo -e "  ${WHITE}curl is a versatile tool for transferring data with URLs.${RESET}"
    echo -e "  ${WHITE}It supports HTTP, HTTPS, FTP, and many other protocols.${RESET}"
    echo ""
    print_command "pkg install curl -y"
    echo ""

    print_subsection "Basic Requests"
    print_command "curl https://example.com                  # GET request"
    print_command "curl -o output.html https://example.com   # Save to file"
    print_command "curl -O https://example.com/file.zip      # Save with original name"
    print_command "curl -I https://example.com               # Headers only"
    print_command "curl -v https://example.com               # Verbose output"
    print_command "curl -s https://example.com               # Silent mode"
    echo ""

    print_subsection "API Interactions"
    print_command "curl -X POST https://api.example.com/data"
    print_command "curl -X POST -d '{\"key\":\"value\"}' -H 'Content-Type: application/json' URL"
    print_command "curl -X PUT -d 'data' URL"
    print_command "curl -X DELETE URL"
    echo ""

    print_subsection "Authentication & Headers"
    print_command "curl -u username:password URL              # Basic auth"
    print_command "curl -H 'Authorization: Bearer TOKEN' URL  # Bearer token"
    print_command "curl -H 'User-Agent: MyApp/1.0' URL       # Custom header"
    echo ""

    print_subsection "Download Features"
    print_command "curl -L URL                                # Follow redirects"
    print_command "curl -C - -O URL                           # Resume download"
    print_command "curl --limit-rate 1M URL                   # Limit speed"
    print_command "curl --progress-bar -O URL                 # Progress bar"

    press_continue

    print_section "5.2 wget - Web Downloader"

    print_command "pkg install wget -y"
    echo ""

    print_subsection "Basic Downloads"
    print_command "wget URL                                   # Download file"
    print_command "wget -O filename URL                       # Specify output name"
    print_command "wget -c URL                                # Continue/resume download"
    print_command "wget -q URL                                # Quiet mode"
    print_command "wget -b URL                                # Background download"
    echo ""

    print_subsection "Advanced wget"
    print_command "wget -r -l 2 URL                           # Recursive, depth 2"
    print_command "wget -m URL                                # Mirror website"
    print_command "wget -i url_list.txt                       # Download from URL list"
    print_command "wget --limit-rate=500k URL                 # Speed limit"
    print_command "wget --spider URL                          # Check if URL exists"
    print_command "wget -P /path/to/dir URL                   # Save to specific dir"

    press_continue

    print_section "5.3 SSH - Secure Shell"

    print_command "pkg install openssh -y"
    echo ""

    print_subsection "SSH Client"
    print_command "ssh user@hostname                          # Connect to server"
    print_command "ssh -p 2222 user@hostname                  # Custom port"
    print_command "ssh -i ~/.ssh/key user@hostname            # Use specific key"
    print_command "ssh user@host 'command'                    # Run remote command"
    echo ""

    print_subsection "SSH Key Management"
    print_command "ssh-keygen -t rsa -b 4096                  # Generate RSA key"
    print_command "ssh-keygen -t ed25519                      # Generate Ed25519 key"
    print_command "ssh-copy-id user@hostname                  # Copy key to server"
    print_command "cat ~/.ssh/id_rsa.pub                      # View public key"
    echo ""

    print_subsection "SSH Server in Termux"
    print_command "sshd                                       # Start SSH server"
    print_command "whoami                                     # Check username"
    print_command "passwd                                     # Set password"
    print_command "ssh localhost -p 8022                      # Default Termux SSH port"
    print_command "pkill sshd                                 # Stop SSH server"
    echo ""
    print_note "Termux SSH server runs on port 8022 by default, not 22"

    press_continue

    print_section "5.4 Network Diagnostics"

    print_subsection "ping - Test Connectivity"
    print_command "ping -c 4 google.com                       # Send 4 pings"
    print_command "ping -c 10 -i 0.5 host                    # 0.5s interval"
    echo ""

    print_subsection "Network Information"
    print_command "ifconfig                                   # Network interfaces"
    print_command "ip addr                                    # IP addresses"
    print_command "ip route                                   # Routing table"
    echo ""

    print_subsection "DNS Tools"
    print_command "pkg install dnsutils -y"
    print_command "nslookup google.com                        # DNS lookup"
    print_command "dig google.com                             # Detailed DNS info"
    print_command "host google.com                            # Simple DNS lookup"
    echo ""

    print_subsection "nmap - Network Scanner"
    print_command "pkg install nmap -y"
    print_command "nmap localhost                              # Scan localhost"
    print_command "nmap -sV hostname                          # Service versions"
    print_command "nmap -p 80,443 hostname                    # Specific ports"
    print_command "nmap -sn 192.168.1.0/24                    # Ping scan subnet"
    echo ""
    print_warning "Only scan networks you own or have permission to scan!"

    press_continue

    print_section "5.5 File Transfer Tools"

    print_subsection "SCP - Secure Copy"
    print_command "scp file.txt user@host:/path/              # Upload file"
    print_command "scp user@host:/path/file.txt .             # Download file"
    print_command "scp -r directory/ user@host:/path/         # Copy directory"
    print_command "scp -P 2222 file user@host:/path/          # Custom port"
    echo ""

    print_subsection "rsync - Advanced Sync"
    print_command "pkg install rsync -y"
    print_command "rsync -avz source/ dest/                   # Local sync"
    print_command "rsync -avz -e ssh source/ user@host:dest/  # Remote sync"
    print_command "rsync -avz --delete source/ dest/          # Mirror (delete extra)"
    print_command "rsync -avzn source/ dest/                  # Dry run (preview)"

    press_continue

    # TRY IT YOURSELF
    try_it_yourself \
        "Practice networking tools:
    1. Check connectivity: ping -c 3 google.com
    2. Fetch a webpage: curl -s -o /dev/null -w '%{http_code}' https://google.com
    3. Check your IP: curl -s ifconfig.me
    4. DNS lookup: nslookup google.com (if dnsutils installed)
    5. View network info: ifconfig or ip addr" \
        "Make sure you have internet connectivity for these exercises"

    press_continue

    # QUIZ
    print_section "Module 5 Quiz"

    ask_multiple_choice \
        "Which curl flag follows HTTP redirects?" \
        "-R" \
        "-L" \
        "-F" \
        "-r" \
        "B" \
        "The -L flag tells curl to follow HTTP redirects (301, 302, etc.)"

    press_continue

    ask_fill_blank \
        "The default SSH port in Termux is ________" \
        "8022" \
        "Termux uses port 8022 instead of the standard port 22."

    press_continue

    ask_multiple_choice \
        "What does 'wget --spider URL' do?" \
        "Downloads the page silently" \
        "Crawls the entire website" \
        "Checks if the URL exists without downloading" \
        "Downloads only spider-related content" \
        "C" \
        "--spider makes wget check if a URL is available without actually downloading it."

    press_continue

    ask_true_false \
        "You should only use nmap on networks you own or have permission to scan." \
        "T" \
        "Unauthorized network scanning is illegal in many jurisdictions."

    press_continue

    # EXERCISE
    print_section "Module 5 Exercises"

    run_exercise 8 \
        "API Data Fetching" \
        "Use curl to fetch data from a public API and save the output." \
        "Try: curl -s 'https://jsonplaceholder.typicode.com/posts/1' > api_data.json && cat api_data.json" \
        "test -f $LESSON_DIR/api_data.json 2>/dev/null && echo 'exists'" \
        "exists"

    press_continue
    print_success "Module 5 Complete! 🎉"
    show_progress_bar 5 $TOTAL_MODULES
    press_continue
}

# ============================================================================
# MODULE 6: TERMUX API & DEVICE INTEGRATION
# ============================================================================

module_06() {
    CURRENT_MODULE=6
    save_progress

    print_header "MODULE 6: Termux API & Device Integration"

    print_section "6.1 Setting Up Termux API"

    echo -e "  ${WHITE}Termux API allows you to access Android device features${RESET}"
    echo -e "  ${WHITE}from the command line, including camera, sensors, SMS,${RESET}"
    echo -e "  ${WHITE}notifications, and more.${RESET}"
    echo ""

    print_subsection "Installation"
    print_command "pkg install termux-api -y"
    print_info "You also need to install the Termux:API app from F-Droid"
    echo ""
    print_warning "The Termux:API Android app must be installed separately!"

    press_continue

    print_section "6.2 Device Information"

    print_subsection "Battery Status"
    print_command "termux-battery-status"
    echo -e "  ${WHITE}Output (JSON):${RESET}"
    echo '    {
      "health": "GOOD",
      "percentage": 85,
      "plugged": "UNPLUGGED",
      "status": "DISCHARGING",
      "temperature": 28.5
    }' | while IFS= read -r line; do echo -e "    ${GREEN}$line${RESET}"; done
    echo ""

    print_subsection "WiFi Information"
    print_command "termux-wifi-connectioninfo"
    print_command "termux-wifi-scaninfo"
    print_command "termux-wifi-enable true"
    print_command "termux-wifi-enable false"
    echo ""

    print_subsection "Device Info"
    print_command "termux-telephony-deviceinfo"
    print_command "termux-telephony-cellinfo"
    print_command "termux-infrared-frequencies"

    press_continue

    print_section "6.3 Notifications & Alerts"

    print_subsection "Toast Messages"
    print_command "termux-toast 'Hello from Termux!'"
    print_command "termux-toast -g middle 'Centered message'"
    print_command "termux-toast -b red -c white 'Warning!'"
    echo ""

    print_subsection "Notifications"
    print_command "termux-notification --title 'Alert' --content 'Task complete!'"
    print_command "termux-notification --title 'Alert' --content 'Done' --id mynotif"
    print_command "termux-notification-remove mynotif"
    print_command "termux-notification-list"
    echo ""

    print_subsection "Vibration"
    print_command "termux-vibrate -d 500                     # Vibrate 500ms"
    print_command "termux-vibrate -f                         # Force vibrate"

    press_continue

    print_section "6.4 Camera & Media"

    print_subsection "Camera"
    print_command "termux-camera-photo -c 0 photo.jpg         # Rear camera"
    print_command "termux-camera-photo -c 1 selfie.jpg        # Front camera"
    print_command "termux-camera-info                         # Camera info"
    echo ""

    print_subsection "Media"
    print_command "termux-media-player play file.mp3          # Play audio"
    print_command "termux-media-player pause"
    print_command "termux-media-player stop"
    print_command "termux-media-player info"
    print_command "termux-media-scan ~/storage/dcim/photo.jpg # Scan media file"
    echo ""

    print_subsection "Text-to-Speech"
    print_command "termux-tts-speak 'Hello, I am Termux'"
    print_command "termux-tts-speak -l en -r 1.5 'Fast speech'"
    print_command "termux-tts-engines                         # List TTS engines"
    echo ""

    print_subsection "Torch/Flashlight"
    print_command "termux-torch on"
    print_command "termux-torch off"

    press_continue

    print_section "6.5 SMS & Contacts"

    print_subsection "SMS Operations"
    print_command "termux-sms-list -l 10                      # List last 10 SMS"
    print_command "termux-sms-list -t inbox                   # Inbox messages"
    print_command "termux-sms-send -n '+1234567890' 'Hello'"
    echo ""
    print_warning "SMS features require appropriate permissions!"
    echo ""

    print_subsection "Contacts"
    print_command "termux-contact-list                        # List all contacts"
    print_command "termux-contact-list | python -m json.tool  # Formatted output"

    press_continue

    print_section "6.6 Sensors & Location"

    print_subsection "Sensors"
    print_command "termux-sensor -l                           # List all sensors"
    print_command "termux-sensor -s 'accelerometer' -n 1      # Read once"
    print_command "termux-sensor -s 'light' -n 5             # Read 5 times"
    echo ""

    print_subsection "Location"
    print_command "termux-location -p gps                     # GPS location"
    print_command "termux-location -p network                 # Network location"
    print_command "termux-location -p passive                 # Passive location"
    echo ""

    print_subsection "Clipboard"
    print_command "termux-clipboard-set 'Hello World'"
    print_command "termux-clipboard-get"
    print_command "echo 'text' | termux-clipboard-set"
    echo ""

    print_subsection "Dialog & Input"
    print_command "termux-dialog confirm -t 'Sure?'"
    print_command "termux-dialog text -t 'Enter name' -i 'hint'"
    print_command "termux-dialog spinner -t 'Choose' -v 'opt1,opt2,opt3'"
    print_command "termux-dialog date -t 'Pick a date'"
    print_command "termux-fingerprint"

    press_continue

    print_section "6.7 Practical API Script Examples"

    echo -e "  ${WHITE}Battery Monitor Script:${RESET}"
    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
# battery_monitor.sh
while true; do
  level=$(termux-battery-status | grep percentage | grep -o '[0-9]*')
  if [ "$level" -lt 20 ]; then
    termux-notification --title "Low Battery" \
      --content "Battery at ${level}%!"
    termux-vibrate -d 1000
  fi
  sleep 300  # Check every 5 minutes
done
SCRIPT
    echo ""

    echo -e "  ${WHITE}Location Logger Script:${RESET}"
    echo "" | print_code_block << 'SCRIPT2'
#!/bin/bash
# location_logger.sh
LOG="location_log.txt"
echo "=== Location Log ===" > $LOG
for i in $(seq 1 5); do
  echo "Reading $i/5..."
  termux-location -p gps >> $LOG
  echo "---" >> $LOG
  sleep 60
done
termux-toast "Location logging complete!"
SCRIPT2

    press_continue

    # TRY IT YOURSELF
    try_it_yourself \
        "Practice Termux API commands (requires Termux:API app):
    1. Check battery: termux-battery-status
    2. Show a toast: termux-toast 'Hello from Termux!'
    3. Copy to clipboard: termux-clipboard-set 'Test text'
    4. Read clipboard: termux-clipboard-get
    5. Vibrate: termux-vibrate -d 200" \
        "You need the Termux:API app installed for these to work"

    press_continue

    # QUIZ
    print_section "Module 6 Quiz"

    ask_multiple_choice \
        "Which package must be installed for Termux API commands?" \
        "termux-tools" \
        "termux-api" \
        "termux-services" \
        "termux-hardware" \
        "B" \
        "Install termux-api package AND the Termux:API Android app."

    press_continue

    ask_fill_blank \
        "To take a photo with the front camera: termux-camera-photo -c ____ selfie.jpg" \
        "1" \
        "Camera 0 is typically the rear camera, camera 1 is the front camera."

    press_continue

    ask_multiple_choice \
        "Which command sends an SMS?" \
        "termux-sms-send -n 'number' 'message'" \
        "termux-send-sms 'number' 'message'" \
        "sms-send 'number' 'message'" \
        "termux-message 'number' 'message'" \
        "A" \
        "termux-sms-send uses -n flag for the phone number."

    press_continue

    print_success "Module 6 Complete! 🎉"
    show_progress_bar 6 $TOTAL_MODULES
    press_continue
}

# ============================================================================
# MODULE 7: SHELL SCRIPTING IN TERMUX
# ============================================================================

module_07() {
    CURRENT_MODULE=7
    save_progress

    print_header "MODULE 7: Shell Scripting in Termux"

    print_section "7.1 Shell Script Basics"

    echo -e "  ${WHITE}A shell script is a file containing a series of commands.${RESET}"
    echo -e "  ${WHITE}It automates tasks and creates complex workflows.${RESET}"
    echo ""

    print_subsection "Creating Your First Script"
    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
# my_first_script.sh
# Author: Emmanuel Suah

echo "Hello, World!"
echo "Today is: $(date)"
echo "You are: $(whoami)"
echo "Current directory: $(pwd)"
SCRIPT

    echo ""
    print_command "nano my_first_script.sh     # Write the script"
    print_command "chmod +x my_first_script.sh # Make executable"
    print_command "./my_first_script.sh        # Run it!"
    echo ""
    print_note "The #!/bin/bash line (shebang) tells the system which interpreter to use"

    press_continue

    print_section "7.2 Variables"

    print_subsection "Variable Declaration & Usage"
    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
# Variables - no spaces around =
NAME="Emmanuel"
AGE=25
GREETING="Hello, $NAME!"

echo $GREETING
echo "Age: $AGE"

# Command substitution
CURRENT_DATE=$(date +%Y-%m-%d)
FILE_COUNT=$(ls | wc -l)

echo "Date: $CURRENT_DATE"
echo "Files: $FILE_COUNT"

# Read user input
echo -n "Enter your name: "
read USER_INPUT
echo "Welcome, $USER_INPUT!"
SCRIPT

    press_continue

    print_subsection "Special Variables"
    echo ""
    echo -e "    ${CYAN}\$0${RESET}  - Script name"
    echo -e "    ${CYAN}\$1-\$9${RESET} - Command line arguments"
    echo -e "    ${CYAN}\$#${RESET}  - Number of arguments"
    echo -e "    ${CYAN}\$@${RESET}  - All arguments (as separate words)"
    echo -e "    ${CYAN}\$*${RESET}  - All arguments (as single word)"
    echo -e "    ${CYAN}\$?${RESET}  - Exit status of last command"
    echo -e "    ${CYAN}\$\$${RESET}  - Current process ID"
    echo -e "    ${CYAN}\$!${RESET}  - PID of last background process"
    echo ""

    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
echo "Script: $0"
echo "First arg: $1"
echo "Second arg: $2"
echo "All args: $@"
echo "Arg count: $#"
SCRIPT

    press_continue

    print_section "7.3 Conditional Statements"

    print_subsection "if/elif/else"
    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
echo -n "Enter a number: "
read NUM

if [ $NUM -gt 100 ]; then
    echo "Greater than 100"
elif [ $NUM -gt 50 ]; then
    echo "Between 51 and 100"
elif [ $NUM -gt 0 ]; then
    echo "Between 1 and 50"
else
    echo "Zero or negative"
fi
SCRIPT

    echo ""
    print_subsection "Comparison Operators"
    echo ""
    echo -e "  ${WHITE}Numeric Comparisons:${RESET}"
    echo -e "    ${CYAN}-eq${RESET}  equal          ${CYAN}-ne${RESET}  not equal"
    echo -e "    ${CYAN}-gt${RESET}  greater than   ${CYAN}-ge${RESET}  greater or equal"
    echo -e "    ${CYAN}-lt${RESET}  less than      ${CYAN}-le${RESET}  less or equal"
    echo ""
    echo -e "  ${WHITE}String Comparisons:${RESET}"
    echo -e "    ${CYAN}==${RESET}   equal          ${CYAN}!=${RESET}   not equal"
    echo -e "    ${CYAN}-z${RESET}   empty string   ${CYAN}-n${RESET}   not empty"
    echo ""
    echo -e "  ${WHITE}File Tests:${RESET}"
    echo -e "    ${CYAN}-f${RESET}   is file        ${CYAN}-d${RESET}   is directory"
    echo -e "    ${CYAN}-e${RESET}   exists         ${CYAN}-r${RESET}   is readable"
    echo -e "    ${CYAN}-w${RESET}   is writable    ${CYAN}-x${RESET}   is executable"
    echo -e "    ${CYAN}-s${RESET}   size > 0       ${CYAN}-L${RESET}   is symlink"

    press_continue

    print_subsection "Case Statement"
    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
echo "Choose an option: (1/2/3)"
read CHOICE

case $CHOICE in
    1)
        echo "You chose option 1"
        ;;
    2)
        echo "You chose option 2"
        ;;
    3)
        echo "You chose option 3"
        ;;
    *)
        echo "Invalid option"
        ;;
esac
SCRIPT

    press_continue

    print_section "7.4 Loops"

    print_subsection "for Loop"
    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
# Iterate over list
for fruit in apple banana cherry; do
    echo "Fruit: $fruit"
done

# C-style for loop
for ((i=1; i<=5; i++)); do
    echo "Count: $i"
done

# Loop over files
for file in *.txt; do
    echo "Processing: $file"
    wc -l "$file"
done

# Loop with command output
for user in $(cat users.txt); do
    echo "User: $user"
done
SCRIPT

    echo ""
    print_subsection "while Loop"
    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
COUNT=1
while [ $COUNT -le 5 ]; do
    echo "Iteration: $COUNT"
    COUNT=$((COUNT + 1))
done

# Read file line by line
while IFS= read -r line; do
    echo "Line: $line"
done < input.txt
SCRIPT

    echo ""
    print_subsection "until Loop"
    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
NUM=1
until [ $NUM -gt 5 ]; do
    echo "Number: $NUM"
    NUM=$((NUM + 1))
done
SCRIPT

    press_continue

    print_section "7.5 Functions"

    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash

# Simple function
greet() {
    echo "Hello, $1!"
}

# Function with return value
add_numbers() {
    local result=$(($1 + $2))
    echo $result
}

# Function with error handling
safe_mkdir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        echo "Directory '$dir' already exists"
        return 1
    else
        mkdir -p "$dir"
        echo "Created directory: $dir"
        return 0
    fi
}

# Using the functions
greet "Emmanuel"
SUM=$(add_numbers 10 20)
echo "Sum: $SUM"
safe_mkdir "new_project"
SCRIPT

    press_continue

    print_section "7.6 Practical Script: System Info Dashboard"

    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
# system_dashboard.sh - by Emmanuel Suah

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}=== System Dashboard ===${RESET}"
echo ""
echo -e "${GREEN}User:${RESET} $(whoami)"
echo -e "${GREEN}Date:${RESET} $(date)"
echo -e "${GREEN}Uptime:${RESET} $(uptime -p 2>/dev/null || uptime)"
echo -e "${GREEN}Disk Usage:${RESET}"
df -h $HOME | tail -1 | awk '{print "  Used:", $3, "/", $2, "("$5")"}'
echo -e "${GREEN}Memory:${RESET}"
free -h 2>/dev/null | grep Mem | awk '{print "  Used:", $3, "/", $2}' || echo "  N/A"
echo -e "${GREEN}Processes:${RESET} $(ps aux 2>/dev/null | wc -l)"
echo -e "${GREEN}Packages:${RESET} $(pkg list-installed 2>/dev/null | wc -l)"
echo ""
echo -e "${CYAN}========================${RESET}"
SCRIPT

    press_continue

    # TRY IT YOURSELF
    setup_workspace
    try_it_yourself \
        "Create and run a shell script:
    1. Create a script: echo '#!/bin/bash' > test_script.sh
    2. Add commands: echo 'echo \"Hello \$1\"' >> test_script.sh
    3. Make executable: chmod +x test_script.sh
    4. Run it: ./test_script.sh World
    5. Try creating a script with a loop or function!" \
        "Remember to add #!/bin/bash as the first line"

    press_continue

    # QUIZ
    print_section "Module 7 Quiz"

    ask_fill_blank \
        "The first line of a bash script should be: #!________" \
        "/bin/bash" \
        "This is called the shebang line and specifies the interpreter."

    press_continue

    ask_multiple_choice \
        "What does \$? contain?" \
        "Current script PID" \
        "Number of arguments" \
        "Exit status of last command" \
        "All arguments" \
        "C" \
        "\$? returns 0 for success, non-zero for failure from the last command."

    press_continue

    ask_multiple_choice \
        "Which operator checks if a file exists?" \
        "-f" \
        "-e" \
        "-d" \
        "-x" \
        "B" \
        "-e checks existence, -f checks if it's a regular file, -d checks if it's a directory."

    press_continue

    ask_fill_blank \
        "To make a script executable: chmod ____ script.sh" \
        "+x" \
        "chmod +x adds execute permission for all users."

    press_continue

    # EXERCISE
    print_section "Module 7 Exercises"

    run_exercise 9 \
        "Create a Backup Script" \
        "Write a bash script that creates a backup of a directory with a timestamp." \
        "Create backup.sh that copies a directory to a timestamped backup." \
        "test -f $LESSON_DIR/backup.sh 2>/dev/null && echo 'exists'" \
        "exists"

    press_continue

    run_exercise 10 \
        "Menu-Driven Script" \
        "Create a script with a menu that offers: 1) Show date, 2) List files, 3) Disk usage, 4) Exit" \
        "Use case statement and a while loop for the menu." \
        "" \
        ""

    press_continue
    print_success "Module 7 Complete! 🎉"
    show_progress_bar 7 $TOTAL_MODULES
    press_continue
}

# ============================================================================
# MODULE 8: PROGRAMMING LANGUAGES & DEVELOPMENT
# ============================================================================

module_08() {
    CURRENT_MODULE=8
    save_progress

    print_header "MODULE 8: Programming Languages & Development"

    print_section "8.1 Python in Termux"

    print_subsection "Installation & Setup"
    print_command "pkg install python -y"
    print_command "python --version"
    print_command "pip install --upgrade pip"
    echo ""

    print_subsection "Running Python"
    print_command "python                         # Interactive shell"
    print_command "python script.py               # Run script"
    print_command "python -c 'print(\"Hello\")'   # One-liner"
    echo ""

    print_subsection "Popular pip Packages"
    print_command "pip install requests           # HTTP library"
    print_command "pip install flask              # Web framework"
    print_command "pip install beautifulsoup4     # Web scraping"
    print_command "pip install numpy              # Numerical computing"
    print_command "pip install pillow             # Image processing"
    print_command "pip install cryptography       # Encryption tools"
    echo ""

    print_subsection "Python Virtual Environments"
    print_command "python -m venv myenv           # Create virtual environment"
    print_command "source myenv/bin/activate      # Activate it"
    print_command "pip install package_name       # Install packages"
    print_command "deactivate                     # Deactivate when done"
    echo ""

    echo -e "  ${WHITE}Example Python Script:${RESET}"
    echo "" | print_code_block << 'SCRIPT'
#!/usr/bin/env python3
# web_scraper.py - Simple URL status checker

import subprocess
try:
    import requests
    urls = ["https://google.com", "https://github.com"]
    for url in urls:
        r = requests.get(url, timeout=5)
        print(f"{url}: {r.status_code}")
except ImportError:
    print("Install requests: pip install requests")
SCRIPT

    press_continue

    print_section "8.2 Node.js in Termux"

    print_subsection "Installation"
    print_command "pkg install nodejs -y"
    print_command "node --version"
    print_command "npm --version"
    echo ""

    print_subsection "Running Node.js"
    print_command "node                           # Interactive REPL"
    print_command "node script.js                 # Run script"
    print_command "node -e 'console.log(\"Hi\")'  # One-liner"
    echo ""

    print_subsection "npm Package Management"
    print_command "npm init -y                    # Initialize project"
    print_command "npm install express            # Install package"
    print_command "npm install -g nodemon         # Install globally"
    print_command "npm list                       # List installed packages"
    echo ""

    echo -e "  ${WHITE}Example: Simple HTTP Server:${RESET}"
    echo "" | print_code_block << 'SCRIPT'
// server.js
const http = require('http');

const server = http.createServer((req, res) => {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.end('<h1>Hello from Termux!</h1>');
});

server.listen(3000, () => {
    console.log('Server at http://localhost:3000');
});
SCRIPT

    press_continue

    print_section "8.3 C/C++ in Termux"

    print_subsection "Installation"
    print_command "pkg install clang -y           # C/C++ compiler"
    print_command "pkg install make -y            # Build tool"
    print_command "pkg install cmake -y           # CMake build system"
    echo ""

    print_subsection "Compiling & Running"
    print_command "clang hello.c -o hello         # Compile C"
    print_command "clang++ hello.cpp -o hello     # Compile C++"
    print_command "./hello                        # Run"
    echo ""

    echo -e "  ${WHITE}Example C Program:${RESET}"
    echo "" | print_code_block << 'SCRIPT'
// hello.c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main() {
    time_t now = time(NULL);
    printf("Hello from Termux!\n");
    printf("Time: %s", ctime(&now));
    printf("Compiled with Clang on Android\n");
    return 0;
}
SCRIPT

    press_continue

    print_section "8.4 Other Languages"

    print_subsection "Ruby"
    print_command "pkg install ruby -y"
    print_command "ruby --version"
    print_command "ruby -e 'puts \"Hello from Ruby!\"'"
    print_command "gem install bundler"
    echo ""

    print_subsection "Go"
    print_command "pkg install golang -y"
    print_command "go version"
    print_command "go run hello.go"
    echo ""

    print_subsection "Rust"
    print_command "pkg install rust -y"
    print_command "rustc --version"
    print_command "rustc hello.rs && ./hello"
    echo ""

    print_subsection "PHP"
    print_command "pkg install php -y"
    print_command "php --version"
    print_command "php -S localhost:8080           # Built-in server"
    echo ""

    print_subsection "Perl"
    print_command "pkg install perl -y"
    print_command "perl -v"
    print_command "perl -e 'print \"Hello Perl\\n\"'"
    echo ""

    print_subsection "Lua"
    print_command "pkg install lua54 -y"
    print_command "lua5.4 -e 'print(\"Hello Lua\")'"

    press_continue

    print_section "8.5 Development Tools"

    print_subsection "Text Editors for Coding"
    print_command "pkg install vim -y             # Vim editor"
    print_command "pkg install nano -y            # Nano editor"
    print_command "pkg install micro -y           # Modern editor"
    print_command "pkg install neovim -y          # Neovim"
    echo ""

    print_subsection "Database Tools"
    print_command "pkg install mariadb -y         # MySQL-compatible"
    print_command "pkg install postgresql -y      # PostgreSQL"
    print_command "pkg install sqlite -y          # SQLite (lightweight)"
    echo ""

    echo -e "  ${WHITE}SQLite Quick Start:${RESET}"
    print_command "sqlite3 mydb.db"
    echo "" | print_code_block << 'SQL'
CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);
INSERT INTO users VALUES (1, 'Emmanuel');
SELECT * FROM users;
.tables
.quit
SQL

    press_continue

    # TRY IT YOURSELF
    setup_workspace
    try_it_yourself \
        "Practice with programming languages:
    1. Python: python -c 'for i in range(5): print(f\"Number: {i}\")'
    2. Create a Python script: echo 'print(\"Hello Python\")' > hello.py
    3. Run it: python hello.py
    4. Try Node.js: node -e 'console.log(2+2)'
    5. Try SQLite: sqlite3 test.db 'CREATE TABLE t(n); INSERT INTO t VALUES(42); SELECT * FROM t;'" \
        "Install the language first with pkg install if needed"

    press_continue

    # QUIZ
    print_section "Module 8 Quiz"

    ask_multiple_choice \
        "Which compiler does Termux use for C/C++?" \
        "gcc" \
        "clang" \
        "msvc" \
        "icc" \
        "B" \
        "Termux uses Clang/LLVM as the default C/C++ compiler."

    press_continue

    ask_fill_blank \
        "To create a Python virtual environment: python -m ________ myenv" \
        "venv" \
        "The venv module creates isolated Python environments."

    press_continue

    ask_multiple_choice \
        "Which database is the lightest weight option in Termux?" \
        "MariaDB" \
        "PostgreSQL" \
        "SQLite" \
        "MongoDB" \
        "C" \
        "SQLite is a file-based database that doesn't require a server process."

    press_continue

    # EXERCISE
    print_section "Module 8 Exercises"

    run_exercise 11 \
        "Multi-Language Hello World" \
        "Create 'Hello World' programs in at least 2 different languages and run them." \
        "Create hello.py and hello.sh (or any other combo) and execute them." \
        "" \
        ""

    press_continue
    print_success "Module 8 Complete! 🎉"
    show_progress_bar 8 $TOTAL_MODULES
    press_continue
}

# ============================================================================
# MODULE 9: SECURITY & PENETRATION TESTING TOOLS
# ============================================================================

module_09() {
    CURRENT_MODULE=9
    save_progress

    print_header "MODULE 9: Security & Penetration Testing Tools"

    echo ""
    echo -e "  ${BG_RED}${WHITE}${BOLD} ⚠ IMPORTANT LEGAL DISCLAIMER ⚠ ${RESET}"
    echo ""
    echo -e "  ${RED}These tools are for EDUCATIONAL purposes and authorized${RESET}"
    echo -e "  ${RED}testing ONLY. Using these tools against systems without${RESET}"
    echo -e "  ${RED}explicit permission is ILLEGAL. Always obtain written${RESET}"
    echo -e "  ${RED}authorization before testing any system.${RESET}"
    echo ""
    echo -e "  ${YELLOW}The author (Emmanuel Suah) and this lesson are not${RESET}"
    echo -e "  ${YELLOW}responsible for any misuse of these tools.${RESET}"
    echo ""

    press_continue

    print_section "9.1 Network Scanning with Nmap"

    print_command "pkg install nmap -y"
    echo ""

    print_subsection "Scan Types"
    print_command "nmap localhost                     # Basic scan"
    print_command "nmap -sV localhost                 # Service version detection"
    print_command "nmap -sS target                   # SYN scan (stealth)"
    print_command "nmap -sU target                   # UDP scan"
    print_command "nmap -sn 192.168.1.0/24           # Host discovery"
    print_command "nmap -O target                    # OS detection"
    print_command "nmap -A target                    # Aggressive scan (all)"
    print_command "nmap -p 1-65535 target            # All ports"
    print_command "nmap -p 80,443,8080 target        # Specific ports"
    print_command "nmap --script=vuln target          # Vulnerability scan"
    echo ""

    print_subsection "Output Formats"
    print_command "nmap -oN output.txt target         # Normal output"
    print_command "nmap -oX output.xml target         # XML output"
    print_command "nmap -oG output.gnmap target       # Grepable output"

    press_continue

    print_section "9.2 Cryptography & Hashing"

    print_subsection "OpenSSL"
    print_command "pkg install openssl-tool -y"
    echo ""
    print_command "echo 'Hello' | openssl md5          # MD5 hash"
    print_command "echo 'Hello' | openssl sha256       # SHA256 hash"
    print_command "openssl rand -hex 32                # Random hex string"
    print_command "openssl rand -base64 32             # Random base64 string"
    echo ""

    print_subsection "File Encryption/Decryption"
    print_command "openssl enc -aes-256-cbc -salt -in file.txt -out file.enc"
    print_info "Encrypt file with AES-256-CBC"
    print_command "openssl enc -aes-256-cbc -d -in file.enc -out file.txt"
    print_info "Decrypt the file"
    echo ""

    print_subsection "Hash Verification"
    print_command "sha256sum file.txt                  # Generate SHA256"
    print_command "md5sum file.txt                     # Generate MD5"
    print_command "sha256sum -c checksum.txt           # Verify checksum"

    press_continue

    print_section "9.3 Password & Security Tools"

    print_subsection "Hydra - Password Cracking"
    print_command "pkg install hydra -y"
    print_command "hydra -l admin -P wordlist.txt target ssh"
    print_info "Brute-force SSH login (ONLY with authorization!)"
    echo ""

    print_subsection "John the Ripper"
    print_command "pkg install john -y"
    print_command "john --wordlist=wordlist.txt hashes.txt"
    print_info "Crack password hashes (educational purposes only)"
    echo ""

    print_subsection "hashcat (if available)"
    print_command "pkg install hashcat -y"
    print_command "hashcat -m 0 hash.txt wordlist.txt"
    print_info "GPU-accelerated hash cracking"

    press_continue

    print_section "9.4 Web Security Tools"

    print_subsection "SQLMap - SQL Injection Testing"
    print_command "pip install sqlmap"
    print_command "sqlmap -u 'http://target/page?id=1' --dbs"
    print_info "Test for SQL injection (authorized testing only!)"
    echo ""

    print_subsection "Nikto - Web Server Scanner"
    print_command "pkg install nikto -y"
    print_command "nikto -h http://target"
    print_info "Scan web server for vulnerabilities"
    echo ""

    print_subsection "Metasploit Framework"
    print_command "pkg install unstable-repo"
    print_command "pkg install metasploit -y"
    print_command "msfconsole"
    print_info "Full penetration testing framework"
    print_warning "Metasploit is a large package (~500MB+)"

    press_continue

    print_section "9.5 Network Monitoring"

    print_subsection "tcpdump - Packet Capture"
    print_command "pkg install tcpdump -y"
    print_command "tcpdump -i any                     # Capture all traffic"
    print_command "tcpdump -i any port 80             # HTTP traffic only"
    print_command "tcpdump -w capture.pcap            # Save to file"
    print_command "tcpdump -r capture.pcap            # Read capture file"
    echo ""

    print_subsection "Wireshark CLI (tshark)"
    print_command "pkg install tshark -y"
    print_command "tshark -i any"
    print_command "tshark -i any -f 'port 443'"

    press_continue

    print_section "9.6 Security Best Practices Script"

    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
# security_audit.sh - Basic Security Checklist
# Author: Emmanuel Suah

echo "=== Termux Security Audit ==="
echo ""

# Check for updates
echo "[*] Checking for package updates..."
UPDATES=$(pkg upgrade -n 2>/dev/null | grep -c "upgraded")
echo "    Packages needing update: $UPDATES"

# Check SSH configuration
echo "[*] Checking SSH..."
if command -v sshd &>/dev/null; then
    if pgrep sshd &>/dev/null; then
        echo "    WARNING: SSH server is running!"
    else
        echo "    OK: SSH server not running"
    fi
fi

# Check open ports
echo "[*] Checking listening ports..."
if command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null
elif command -v netstat &>/dev/null; then
    netstat -tlnp 2>/dev/null
fi

# Check file permissions
echo "[*] Checking home directory permissions..."
HOME_PERMS=$(stat -c %a $HOME 2>/dev/null || stat -f %Lp $HOME 2>/dev/null)
echo "    Home dir permissions: $HOME_PERMS"

echo ""
echo "=== Audit Complete ==="
SCRIPT

    press_continue

    # QUIZ
    print_section "Module 9 Quiz"

    ask_true_false \
        "It's okay to use nmap to scan any public website without permission." \
        "F" \
        "Scanning systems without authorization is illegal in most jurisdictions."

    press_continue

    ask_multiple_choice \
        "Which nmap flag detects service versions?" \
        "-sS" \
        "-sV" \
        "-sN" \
        "-sU" \
        "B" \
        "-sV probes open ports to determine service/version info."

    press_continue

    ask_fill_blank \
        "To generate a random 32-byte hex string: openssl rand -______ 32" \
        "hex" \
        "openssl rand -hex generates random hexadecimal strings."

    press_continue

    print_success "Module 9 Complete! 🎉"
    show_progress_bar 9 $TOTAL_MODULES
    press_continue
}

# ============================================================================
# MODULE 10: GIT & VERSION CONTROL
# ============================================================================

module_10() {
    CURRENT_MODULE=10
    save_progress

    print_header "MODULE 10: Git & Version Control"

    print_section "10.1 Git Setup"

    print_command "pkg install git -y"
    echo ""

    print_subsection "Initial Configuration"
    print_command "git config --global user.name 'Your Name'"
    print_command "git config --global user.email 'your@email.com'"
    print_command "git config --global init.defaultBranch main"
    print_command "git config --global core.editor nano"
    print_command "git config --list                  # View all config"

    press_continue

    print_section "10.2 Basic Git Workflow"

    echo -e "  ${WHITE}The Git workflow:${RESET}"
    echo ""
    echo -e "    ${CYAN}Working Dir${RESET} → ${YELLOW}Staging Area${RESET} → ${GREEN}Repository${RESET} → ${MAGENTA}Remote${RESET}"
    echo -e "       (edit)       (git add)     (git commit)  (git push)"
    echo ""

    print_subsection "Creating a Repository"
    print_command "mkdir my_project && cd my_project"
    print_command "git init                           # Initialize new repo"
    echo ""

    print_subsection "Basic Commands"
    print_command "git status                         # Check status"
    print_command "git add file.txt                   # Stage a file"
    print_command "git add .                          # Stage all changes"
    print_command "git commit -m 'Initial commit'     # Commit changes"
    print_command "git log                            # View history"
    print_command "git log --oneline                  # Compact history"
    print_command "git log --graph --oneline --all    # Visual branch graph"
    print_command "git diff                           # Show unstaged changes"
    print_command "git diff --staged                  # Show staged changes"

    press_continue

    print_section "10.3 Branching & Merging"

    print_subsection "Branch Operations"
    print_command "git branch                         # List branches"
    print_command "git branch feature-login           # Create branch"
    print_command "git checkout feature-login         # Switch to branch"
    print_command "git checkout -b new-feature        # Create & switch"
    print_command "git switch main                    # Switch (modern way)"
    print_command "git branch -d branch-name          # Delete branch"
    echo ""

    print_subsection "Merging"
    print_command "git checkout main"
    print_command "git merge feature-login            # Merge branch"
    print_command "git merge --no-ff feature          # Force merge commit"
    echo ""

    print_subsection "Handling Merge Conflicts"
    echo "" | print_code_block << 'TEXT'
<<<<<<< HEAD
Your changes on main
=======
Changes from feature branch
>>>>>>> feature-login
TEXT
    echo ""
    print_info "Edit the file to resolve, then: git add file && git commit"

    press_continue

    print_section "10.4 Remote Repositories"

    print_subsection "Working with Remotes"
    print_command "git remote add origin URL           # Add remote"
    print_command "git remote -v                       # List remotes"
    print_command "git push -u origin main             # Push to remote"
    print_command "git pull origin main                # Pull from remote"
    print_command "git fetch origin                    # Fetch without merge"
    print_command "git clone URL                       # Clone a repository"
    echo ""

    print_subsection "SSH Keys for GitHub"
    print_command "ssh-keygen -t ed25519 -C 'email@example.com'"
    print_command "cat ~/.ssh/id_ed25519.pub"
    print_info "Copy the public key to GitHub → Settings → SSH Keys"
    print_command "ssh -T git@github.com               # Test connection"

    press_continue

    print_section "10.5 Advanced Git"

    print_subsection "Stashing Changes"
    print_command "git stash                           # Stash changes"
    print_command "git stash list                      # List stashes"
    print_command "git stash pop                       # Apply & remove stash"
    print_command "git stash apply                     # Apply, keep stash"
    print_command "git stash drop                      # Remove a stash"
    echo ""

    print_subsection "Undoing Changes"
    print_command "git checkout -- file.txt             # Discard changes"
    print_command "git restore file.txt                 # Modern discard"
    print_command "git reset HEAD file.txt              # Unstage file"
    print_command "git reset --soft HEAD~1              # Undo last commit (keep changes)"
    print_command "git reset --hard HEAD~1              # Undo last commit (lose changes!)"
    print_command "git revert HEAD                      # Create undo commit"
    echo ""

    print_subsection "Tags"
    print_command "git tag v1.0                        # Lightweight tag"
    print_command "git tag -a v1.0 -m 'Release 1.0'   # Annotated tag"
    print_command "git push origin --tags              # Push tags"

    press_continue

    print_section "10.6 Git Aliases (Productivity)"

    echo "" | print_code_block << 'CONFIG'
# Add these to your ~/.gitconfig
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.lg "log --oneline --graph --all"
git config --global alias.last "log -1 HEAD"
git config --global alias.unstage "reset HEAD --"
CONFIG

    press_continue

    # TRY IT YOURSELF
    setup_workspace
    try_it_yourself \
        "Practice Git:
    1. Create a directory: mkdir git_practice && cd git_practice
    2. Initialize repo: git init
    3. Create a file: echo 'Hello Git' > readme.md
    4. Check status: git status
    5. Stage the file: git add readme.md
    6. Commit: git commit -m 'First commit'
    7. Create a branch: git checkout -b feature
    8. Make changes: echo 'New feature' >> readme.md
    9. Commit: git add . && git commit -m 'Add feature'
    10. Merge: git checkout main && git merge feature" \
        "Git must be installed: pkg install git"

    press_continue

    # QUIZ
    print_section "Module 10 Quiz"

    ask_multiple_choice \
        "What does 'git add .' do?" \
        "Adds only new files" \
        "Stages all changes in current directory" \
        "Commits all changes" \
        "Pushes to remote" \
        "B" \
        "git add . stages all modified, deleted, and new files in the current directory."

    press_continue

    ask_fill_blank \
        "To create and switch to a new branch: git checkout ____ new-branch" \
        "-b" \
        "The -b flag creates a new branch and switches to it immediately."

    press_continue

    ask_multiple_choice \
        "Which command undoes the last commit but keeps changes staged?" \
        "git reset --hard HEAD~1" \
        "git reset --soft HEAD~1" \
        "git revert HEAD" \
        "git undo" \
        "B" \
        "--soft keeps changes staged, --hard discards them, revert creates a new undo commit."

    press_continue

    ask_true_false \
        "git fetch downloads changes and automatically merges them." \
        "F" \
        "git fetch only downloads, git pull fetches AND merges."

    press_continue

    # EXERCISE
    print_section "Module 10 Exercises"

    run_exercise 12 \
        "Git Workflow Practice" \
        "Create a repo with at least 3 commits on main and a feature branch." \
        "Initialize a repo, make commits, create a branch, and merge it back." \
        "" \
        ""

    press_continue
    print_success "Module 10 Complete! 🎉"
    show_progress_bar 10 $TOTAL_MODULES
    press_continue
}

# ============================================================================
# MODULE 11: ADVANCED SYSTEM TOOLS & AUTOMATION
# ============================================================================

module_11() {
    CURRENT_MODULE=11
    save_progress

    print_header "MODULE 11: Advanced System Tools & Automation"

    print_section "11.1 Process Management"

    print_subsection "Viewing Processes"
    print_command "ps                                # Current session processes"
    print_command "ps aux                            # All processes"
    print_command "ps aux | grep python              # Find specific process"
    print_command "top                               # Live process monitor"
    print_command "htop                              # Interactive process monitor"
    print_command "pkg install htop -y"
    echo ""

    print_subsection "Managing Processes"
    print_command "command &                         # Run in background"
    print_command "jobs                              # List background jobs"
    print_command "fg %1                             # Bring job 1 to foreground"
    print_command "bg %1                             # Resume job 1 in background"
    print_command "kill PID                          # Kill process by PID"
    print_command "kill -9 PID                       # Force kill"
    print_command "killall process_name              # Kill by name"
    print_command "pkill -f 'pattern'                # Kill by pattern"
    echo ""

    print_subsection "nohup & screen"
    print_command "nohup command &                   # Survive terminal close"
    print_command "nohup command > output.log 2>&1 & # With logging"
    echo ""
    print_command "pkg install screen -y"
    print_command "screen                            # Start screen session"
    print_command "screen -S myname                  # Named session"
    print_command "screen -ls                        # List sessions"
    print_command "screen -r myname                  # Reattach to session"
    print_info "Inside screen: Ctrl+A then D to detach"

    press_continue

    print_section "11.2 tmux - Terminal Multiplexer"

    print_command "pkg install tmux -y"
    echo ""

    print_subsection "Basic tmux Usage"
    print_command "tmux                              # Start tmux"
    print_command "tmux new -s session_name          # Named session"
    print_command "tmux ls                           # List sessions"
    print_command "tmux attach -t session_name       # Reattach"
    print_command "tmux kill-session -t name         # Kill session"
    echo ""

    print_subsection "tmux Key Bindings (prefix: Ctrl+B)"
    echo -e "    ${CYAN}Ctrl+B then %${RESET}     Split horizontally"
    echo -e "    ${CYAN}Ctrl+B then \"${RESET}     Split vertically"
    echo -e "    ${CYAN}Ctrl+B then ←→↑↓${RESET}  Navigate panes"
    echo -e "    ${CYAN}Ctrl+B then c${RESET}     New window"
    echo -e "    ${CYAN}Ctrl+B then n/p${RESET}   Next/Previous window"
    echo -e "    ${CYAN}Ctrl+B then d${RESET}     Detach from session"
    echo -e "    ${CYAN}Ctrl+B then x${RESET}     Close current pane"
    echo -e "    ${CYAN}Ctrl+B then z${RESET}     Zoom pane (toggle)"
    echo -e "    ${CYAN}Ctrl+B then [${RESET}     Scroll mode (q to exit)"

    press_continue

    print_section "11.3 Task Scheduling with cron"

    print_command "pkg install cronie -y"
    echo ""

    print_subsection "crontab Format"
    echo "" | print_code_block << 'CRON'
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of week (0-7, Sun=0,7)
# │ │ │ │ │
# * * * * * command_to_execute
CRON
    echo ""

    print_subsection "crontab Commands"
    print_command "crontab -e                        # Edit crontab"
    print_command "crontab -l                        # List crontab"
    print_command "crontab -r                        # Remove crontab"
    echo ""

    print_subsection "Common Schedules"
    echo -e "    ${GREEN}*/5 * * * *${RESET}    Every 5 minutes"
    echo -e "    ${GREEN}0 * * * *${RESET}      Every hour"
    echo -e "    ${GREEN}0 9 * * *${RESET}      Daily at 9 AM"
    echo -e "    ${GREEN}0 0 * * 0${RESET}      Every Sunday midnight"
    echo -e "    ${GREEN}0 0 1 * *${RESET}      First of every month"
    echo -e "    ${GREEN}@reboot${RESET}        On system boot"

    press_continue

    print_section "11.4 Advanced Piping & Redirection"

    print_subsection "Redirection"
    echo -e "    ${GREEN}>${RESET}     Redirect stdout (overwrite)"
    echo -e "    ${GREEN}>>${RESET}    Redirect stdout (append)"
    echo -e "    ${GREEN}2>${RESET}    Redirect stderr"
    echo -e "    ${GREEN}2>>${RESET}   Redirect stderr (append)"
    echo -e "    ${GREEN}&>${RESET}    Redirect both stdout and stderr"
    echo -e "    ${GREEN}<${RESET}     Redirect stdin from file"
    echo -e "    ${GREEN}<<${RESET}    Here document"
    echo ""

    print_subsection "Piping & Chaining"
    print_command "cmd1 | cmd2                       # Pipe output"
    print_command "cmd1 | tee file.txt | cmd2        # Pipe + save"
    print_command "cmd1 && cmd2                      # Run cmd2 if cmd1 succeeds"
    print_command "cmd1 || cmd2                      # Run cmd2 if cmd1 fails"
    print_command "cmd1 ; cmd2                       # Run both regardless"
    echo ""

    print_subsection "Process Substitution"
    print_command "diff <(sort file1) <(sort file2)  # Compare sorted files"
    print_command "comm <(sort file1) <(sort file2)  # Common lines"
    echo ""

    print_subsection "xargs - Build Commands from Input"
    print_command "find . -name '*.log' | xargs rm   # Delete found files"
    print_command "cat urls.txt | xargs -I {} curl -O {}"
    print_info "Download each URL in the list"
    print_command "echo '1 2 3 4 5' | xargs -n 1     # One arg per line"
    print_command "find . -name '*.py' | xargs wc -l  # Count Python lines"

    press_continue

    print_section "11.5 System Monitoring Scripts"

    echo -e "  ${WHITE}Comprehensive System Monitor:${RESET}"
    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
# system_monitor.sh - Author: Emmanuel Suah

LOG="system_monitor.log"

monitor() {
    echo "=== $(date) ===" >> $LOG

    # Disk usage
    echo "DISK:" >> $LOG
    df -h $HOME | tail -1 >> $LOG

    # Running processes
    echo "PROCESSES: $(ps aux | wc -l)" >> $LOG

    # Top 5 memory processes
    echo "TOP MEMORY:" >> $LOG
    ps aux --sort=-%mem 2>/dev/null | head -6 >> $LOG

    echo "---" >> $LOG
}

echo "Starting monitor (Ctrl+C to stop)..."
while true; do
    monitor
    echo "Logged at $(date)"
    sleep 60
done
SCRIPT

    press_continue

    print_section "11.6 Termux Boot & Startup Scripts"

    print_command "pkg install termux-services -y"
    echo ""

    print_subsection "Termux:Boot Setup"
    echo -e "  ${WHITE}Install Termux:Boot app, then:${RESET}"
    print_command "mkdir -p ~/.termux/boot/"
    echo ""
    echo -e "  ${WHITE}Create startup script:${RESET}"
    echo "" | print_code_block << 'SCRIPT'
#!/bin/bash
# ~/.termux/boot/startup.sh
# Runs when device boots (with Termux:Boot)

# Start SSH server
sshd

# Start a monitoring script
nohup ~/scripts/monitor.sh &

# Send notification
termux-notification \
  --title "Termux Started" \
  --content "Background services are running"
SCRIPT
    echo ""
    print_command "chmod +x ~/.termux/boot/startup.sh"

    press_continue

    # TRY IT YOURSELF
    try_it_yourself \
        "Practice advanced tools:
    1. Start a background process: sleep 100 &
    2. List jobs: jobs
    3. Check its PID: ps aux | grep sleep
    4. Kill it: kill %1
    5. Try tmux: tmux new -s test (Ctrl+B then d to detach)
    6. List tmux sessions: tmux ls
    7. Reattach: tmux attach -t test" \
        "Use Ctrl+C or kill to stop runaway processes"

    press_continue

    # QUIZ
    print_section "Module 11 Quiz"

    ask_multiple_choice \
        "What does 'nohup command &' do?" \
        "Runs command at highest priority" \
        "Runs command that survives terminal closing" \
        "Runs command without output" \
        "Runs command as root" \
        "B" \
        "nohup prevents the process from being killed when the terminal closes."

    press_continue

    ask_fill_blank \
        "In cron, '*/5 * * * *' means run every ____ minutes" \
        "5" \
        "The */5 in the minute field means every 5 minutes."

    press_continue

    ask_multiple_choice \
        "In tmux, what key combination splits the terminal horizontally?" \
        "Ctrl+B then %" \
        "Ctrl+B then |" \
        "Ctrl+A then %" \
        "Ctrl+B then -" \
        "A" \
        "Ctrl+B is the default prefix, then % splits horizontally."

    press_continue

    ask_multiple_choice \
        "What does '2>&1' do in redirection?" \
        "Redirects stdout to file 2" \
        "Redirects stderr to stdout" \
        "Redirects file 2 to file 1" \
        "Creates 2 copies of output" \
        "B" \
        "2>&1 redirects stderr (file descriptor 2) to wherever stdout (1) is going."

    press_continue

    # EXERCISE
    print_section "Module 11 Exercises"

    run_exercise 13 \
        "Create an Automated Backup Script" \
        "Write a script that backs up your home directory to a tar archive with a date stamp." \
        "The script should create: backup_YYYY-MM-DD.tar.gz" \
        "test -f $LESSON_DIR/automated_backup.sh 2>/dev/null && echo 'exists'" \
        "exists"

    press_continue
    print_success "Module 11 Complete! 🎉"
    show_progress_bar 11 $TOTAL_MODULES
    press_continue
}

# ============================================================================
# MODULE 12: FINAL COMPREHENSIVE PROJECT & ASSESSMENT
# ============================================================================

module_12() {
    CURRENT_MODULE=12
    save_progress

    print_header "MODULE 12: Final Project & Assessment"

    print_section "12.1 Course Review"

    echo -e "  ${WHITE}Congratulations on making it to the final module! 🎓${RESET}"
    echo -e "  ${WHITE}Let's review what you've learned:${RESET}"
    echo ""
    echo -e "    ${GREEN}✔${RESET} Module 1:  Termux basics and setup"
    echo -e "    ${GREEN}✔${RESET} Module 2:  Package management with pkg/apt"
    echo -e "    ${GREEN}✔${RESET} Module 3:  File system navigation and management"
    echo -e "    ${GREEN}✔${RESET} Module 4:  Text processing (grep, sed, awk)"
    echo -e "    ${GREEN}✔${RESET} Module 5:  Networking tools (curl, wget, SSH, nmap)"
    echo -e "    ${GREEN}✔${RESET} Module 6:  Termux API and device integration"
    echo -e "    ${GREEN}✔${RESET} Module 7:  Shell scripting"
    echo -e "    ${GREEN}✔${RESET} Module 8:  Programming languages in Termux"
    echo -e "    ${GREEN}✔${RESET} Module 9:  Security tools"
    echo -e "    ${GREEN}✔${RESET} Module 10: Git version control"
    echo -e "    ${GREEN}✔${RESET} Module 11: Advanced system tools & automation"

    press_continue

    print_section "12.2 Final Comprehensive Quiz"

    echo -e "  ${BG_MAGENTA}${WHITE}${BOLD} 📝 FINAL ASSESSMENT - 15 Questions ${RESET}"
    echo ""
    echo -e "  ${WHITE}This assessment covers all modules. Good luck!${RESET}"

    press_continue

    # Question 1
    ask_multiple_choice \
        "What is the PREFIX path in Termux?" \
        "/usr" \
        "/data/data/com.termux/files/usr" \
        "/system/usr" \
        "/home/usr" \
        "B" \
        "PREFIX points to Termux's usr directory."

    press_continue

    # Question 2
    ask_fill_blank \
        "Command to install multiple packages: pkg ________ python git nodejs" \
        "install" \
        "pkg install can accept multiple package names."

    press_continue

    # Question 3
    ask_multiple_choice \
        "Which flag makes mkdir create parent directories?" \
        "-r" \
        "-f" \
        "-p" \
        "-v" \
        "C" \
        "mkdir -p creates the entire directory path including parents."

    press_continue

    # Question 4
    ask_multiple_choice \
        "What does 'grep -rn pattern dir/' do?" \
        "Recursive search showing line numbers" \
        "Reverse search in network mode" \
        "Remove pattern from all files" \
        "Rename files matching pattern" \
        "A" \
        "-r is recursive, -n shows line numbers."

    press_continue

    # Question 5
    ask_fill_blank \
        "To download a file with curl and save it: curl -____ output.html URL" \
        "o" \
        "The -o flag specifies the output filename."

    press_continue

    # Question 6
    ask_true_false \
        "The Termux API can access the device camera." \
        "T" \
        "termux-camera-photo can take photos using the device cameras."

    press_continue

    # Question 7
    ask_multiple_choice \
        "In a bash script, what does '\$#' represent?" \
        "The last argument" \
        "The process ID" \
        "The number of arguments" \
        "The script name" \
        "C" \
        "\$# gives the count of command-line arguments passed to the script."

    press_continue

    # Question 8
    ask_multiple_choice \
        "Which command compiles a C program in Termux?" \
        "gcc program.c" \
        "cc program.c" \
        "clang program.c" \
        "compile program.c" \
        "C" \
        "Termux uses Clang as its C/C++ compiler."

    press_continue

    # Question 9
    ask_fill_blank \
        "To stage all changes in git: git ____ ." \
        "add" \
        "git add . stages all changes in the current directory."

    press_continue

    # Question 10
    ask_multiple_choice \
        "What does 'sed -i s/old/new/g file' do?" \
        "Shows differences between old and new" \
        "Replaces 'old' with 'new' in file, in place" \
        "Creates a new file" \
        "Searches for 'old' and 'new'" \
        "B" \
        "-i edits in place, s/ is substitute, g is global (all occurrences)."

    press_continue

    # Question 11
    ask_true_false \
        "tmux sessions persist even after closing the terminal." \
        "T" \
        "tmux sessions run in the background and can be reattached later."

    press_continue

    # Question 12
    ask_multiple_choice \
        "What awk command prints the third column of a file?" \
        "awk '{print \$3}' file" \
        "awk -c3 file" \
        "awk column=3 file" \
        "awk print(3) file" \
        "A" \
        "\$3 refers to the third field in awk."

    press_continue

    # Question 13
    ask_fill_blank \
        "To check battery status with Termux API: termux-__________-status" \
        "battery" \
        "termux-battery-status returns JSON data about the battery."

    press_continue

    # Question 14
    ask_multiple_choice \
        "Which redirection sends both stdout and stderr to a file?" \
        "> file" \
        ">> file" \
        "&> file" \
        "2> file" \
        "C" \
        "&> redirects both standard output and standard error to the file."

    press_continue

    # Question 15
    ask_multiple_choice \
        "What is the correct shebang for a bash script?" \
        "#/bin/bash" \
        "#!/bin/bash" \
        "##/bin/bash" \
        "#!bash" \
        "B" \
        "The shebang must be #! followed by the interpreter path."

    press_continue

    print_section "12.3 Final Project"

    echo -e "  ${BG_RED}${WHITE}${BOLD} 🏗 CAPSTONE PROJECT ${RESET}"
    echo ""
    echo -e "  ${WHITE}${BOLD}Project: Build a Termux System Toolkit${RESET}"
    echo ""
    echo -e "  ${WHITE}Create a comprehensive bash script called ${BOLD}toolkit.sh${RESET}${WHITE} that:${RESET}"
    echo ""
    echo -e "    ${CYAN}1.${RESET} Displays a menu with the following options:"
    echo -e "    ${CYAN}2.${RESET} System Information (user, date, uptime, disk usage)"
    echo -e "    ${CYAN}3.${RESET} Package Manager (search, install, list packages)"
    echo -e "    ${CYAN}4.${RESET} File Operations (create, find, backup files)"
    echo -e "    ${CYAN}5.${RESET} Network Tools (ping, curl check, port scan)"
    echo -e "    ${CYAN}6.${RESET} Text Processing (word count, search in files)"
    echo -e "    ${CYAN}7.${RESET} Logs and history management"
    echo -e "    ${CYAN}8.${RESET} Exit option"
    echo ""
    echo -e "  ${YELLOW}Requirements:${RESET}"
    echo -e "    ${GREEN}●${RESET} Use functions for each menu option"
    echo -e "    ${GREEN}●${RESET} Include error handling"
    echo -e "    ${GREEN}●${RESET} Use colors for output"
    echo -e "    ${GREEN}●${RESET} Log all operations to a file"
    echo -e "    ${GREEN}●${RESET} Include a help option"
    echo ""

    echo -e "  ${WHITE}Here's a starter template:${RESET}"
    echo "" | print_code_block << 'PROJECT'
#!/bin/bash
# toolkit.sh - Termux System Toolkit
# Author: [Your Name]
# Final Project - Termux Tools Masterclass

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'
LOG="toolkit.log"

log_action() {
    echo "[$(date)] $1" >> $LOG
}

show_menu() {
    clear
    echo -e "${CYAN}=== Termux Toolkit ===${RESET}"
    echo "1) System Info"
    echo "2) Package Manager"
    echo "3) File Operations"
    echo "4) Network Tools"
    echo "5) Text Processing"
    echo "6) View Logs"
    echo "7) Help"
    echo "8) Exit"
    echo ""
    echo -n "Choose: "
}

system_info() {
    log_action "System info requested"
    echo -e "${GREEN}=== System Info ===${RESET}"
    echo "User: $(whoami)"
    echo "Date: $(date)"
    echo "PWD:  $(pwd)"
    df -h $HOME | tail -1
}

# Add more functions here...

# Main loop
while true; do
    show_menu
    read choice
    case $choice in
        1) system_info ;;
        8) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option" ;;
    esac
    read -p "Press Enter to continue..."
done
PROJECT

    press_continue

    # TRY IT YOURSELF
    try_it_yourself \
        "Build your final project toolkit.sh!

    Start with the template provided, then add:
    - Package management functions
    - File operation functions
    - Network tool functions
    - Text processing functions
    - Error handling throughout

    When done, test all features and verify they work." \
        "Start simple and add features incrementally. Test each function as you go."

    press_continue

    run_exercise 14 \
        "Final Project Submission" \
        "Create the toolkit.sh script with at least 4 working menu options." \
        "Build and test your toolkit. Type 'verify' when complete." \
        "test -f $LESSON_DIR/toolkit.sh 2>/dev/null && echo 'exists'" \
        "exists"

    press_continue
    print_success "Module 12 Complete! 🎉"
    show_progress_bar 12 $TOTAL_MODULES
    press_continue
}

# ============================================================================
# FINAL RESULTS
# ============================================================================

show_final_results() {
    clear_screen

    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║         🎓  COURSE COMPLETION REPORT  🎓                    ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${RESET}"

    echo ""
    echo -e "  ${WHITE}${BOLD}Student: $USER_NAME${RESET}"
    echo -e "  ${WHITE}Course: Termux Tools Masterclass${RESET}"
    echo -e "  ${WHITE}Author: Emmanuel Suah${RESET}"
    echo -e "  ${WHITE}Date: $(date '+%B %d, %Y')${RESET}"
    echo ""
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""

    # Calculate percentage
    if [[ $TOTAL_QUESTIONS -gt 0 ]]; then
        PERCENTAGE=$((SCORE * 100 / TOTAL_QUESTIONS))
    else
        PERCENTAGE=0
    fi

    echo -e "  ${WHITE}${BOLD}QUIZ & EXERCISE RESULTS:${RESET}"
    echo ""
    echo -e "  ${GREEN}Correct Answers:${RESET} $SCORE"
    echo -e "  ${RED}Total Questions:${RESET} $TOTAL_QUESTIONS"
    echo -e "  ${CYAN}Score:${RESET} ${BOLD}$PERCENTAGE%${RESET}"
    echo ""

    # Progress bar
    show_progress_bar "$SCORE" "$TOTAL_QUESTIONS"
    echo ""

    # Grade
    echo -ne "  ${WHITE}${BOLD}Grade: ${RESET}"
    if [[ $PERCENTAGE -ge 90 ]]; then
        echo -e "${GREEN}${BOLD}A+ EXCELLENT! 🌟🌟🌟${RESET}"
        echo ""
        echo -e "  ${GREEN}Outstanding work, $USER_NAME! You've mastered Termux tools!${RESET}"
    elif [[ $PERCENTAGE -ge 80 ]]; then
        echo -e "${GREEN}${BOLD}A  GREAT JOB! 🌟🌟${RESET}"
        echo ""
        echo -e "  ${GREEN}Excellent performance! You have a strong grasp of Termux.${RESET}"
    elif [[ $PERCENTAGE -ge 70 ]]; then
        echo -e "${YELLOW}${BOLD}B  GOOD! 🌟${RESET}"
        echo ""
        echo -e "  ${YELLOW}Good work! Review the modules where you had difficulty.${RESET}"
    elif [[ $PERCENTAGE -ge 60 ]]; then
        echo -e "${YELLOW}${BOLD}C  SATISFACTORY${RESET}"
        echo ""
        echo -e "  ${YELLOW}You've passed! Consider reviewing challenging topics.${RESET}"
    elif [[ $PERCENTAGE -ge 50 ]]; then
        echo -e "${ORANGE}${BOLD}D  NEEDS IMPROVEMENT${RESET}"
        echo ""
        echo -e "  ${ORANGE}Keep practicing! Re-run the course to strengthen your skills.${RESET}"
    else
        echo -e "${RED}${BOLD}F  KEEP TRYING${RESET}"
        echo ""
        echo -e "  ${RED}Don't give up! Run the course again and practice more.${RESET}"
    fi

    echo ""
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "  ${WHITE}${BOLD}MODULES COMPLETED:${RESET}"
    echo ""
    show_progress_bar "$CURRENT_MODULE" "$TOTAL_MODULES"
    echo ""
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "  ${WHITE}${BOLD}SKILLS ACQUIRED:${RESET}"
    echo ""
    [[ $CURRENT_MODULE -ge 1 ]]  && echo -e "    ${GREEN}✔${RESET} Terminal Navigation & Setup"
    [[ $CURRENT_MODULE -ge 2 ]]  && echo -e "    ${GREEN}✔${RESET} Package Management"
    [[ $CURRENT_MODULE -ge 3 ]]  && echo -e "    ${GREEN}✔${RESET} File System Operations"
    [[ $CURRENT_MODULE -ge 4 ]]  && echo -e "    ${GREEN}✔${RESET} Text Processing (grep, sed, awk)"
    [[ $CURRENT_MODULE -ge 5 ]]  && echo -e "    ${GREEN}✔${RESET} Networking (curl, SSH, nmap)"
    [[ $CURRENT_MODULE -ge 6 ]]  && echo -e "    ${GREEN}✔${RESET} Termux API Integration"
    [[ $CURRENT_MODULE -ge 7 ]]  && echo -e "    ${GREEN}✔${RESET} Shell Scripting"
    [[ $CURRENT_MODULE -ge 8 ]]  && echo -e "    ${GREEN}✔${RESET} Programming Languages"
    [[ $CURRENT_MODULE -ge 9 ]]  && echo -e "    ${GREEN}✔${RESET} Security Tools"
    [[ $CURRENT_MODULE -ge 10 ]] && echo -e "    ${GREEN}✔${RESET} Git Version Control"
    [[ $CURRENT_MODULE -ge 11 ]] && echo -e "    ${GREEN}✔${RESET} System Administration"
    [[ $CURRENT_MODULE -ge 12 ]] && echo -e "    ${GREEN}✔${RESET} Complete System Toolkit Development"
    echo ""
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "  ${WHITE}${BOLD}NEXT STEPS:${RESET}"
    echo -e "    ${CYAN}1.${RESET} Practice daily with Termux"
    echo -e "    ${CYAN}2.${RESET} Build your own automation scripts"
    echo -e "    ${CYAN}3.${RESET} Contribute to open-source projects"
    echo -e "    ${CYAN}4.${RESET} Explore Termux community packages"
    echo -e "    ${CYAN}5.${RESET} Join Termux communities on Reddit/GitHub"
    echo ""
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "  ${MAGENTA}Thank you for taking this course!${RESET}"
    echo -e "  ${MAGENTA}Created with ❤ by Emmanuel Suah${RESET}"
    echo ""
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    # Save final results
    save_progress

    # Generate certificate file
    cat > "$HOME/termux_certificate_${USER_NAME}.txt" << CERT
═══════════════════════════════════════════════════════════════
                    CERTIFICATE OF COMPLETION

    This certifies that

                        $USER_NAME

    has successfully completed the

            TERMUX TOOLS MASTERCLASS

    Score: $SCORE/$TOTAL_QUESTIONS ($PERCENTAGE%)
    Date: $(date '+%B %d, %Y')

    Instructor: Emmanuel Suah

═══════════════════════════════════════════════════════════════
CERT

    echo ""
    echo -e "  ${GREEN}📜 Certificate saved to: ~/termux_certificate_${USER_NAME}.txt${RESET}"
    echo ""

    press_continue
}

# ============================================================================
# MAIN PROGRAM
# ============================================================================

main() {
    # Setup
    setup_workspace

    # Welcome
    show_welcome

    # Table of Contents
    show_table_of_contents

    # Run modules based on progress
    case $CURRENT_MODULE in
        0|1)
            module_01
            ;&
        1|2)
            [[ $CURRENT_MODULE -le 1 ]] && module_02
            ;&
        2|3)
            [[ $CURRENT_MODULE -le 2 ]] && module_03
            ;&
        3|4)
            [[ $CURRENT_MODULE -le 3 ]] && module_04
            ;&
        4|5)
            [[ $CURRENT_MODULE -le 4 ]] && module_05
            ;&
        5|6)
            [[ $CURRENT_MODULE -le 5 ]] && module_06
            ;&
        6|7)
            [[ $CURRENT_MODULE -le 6 ]] && module_07
            ;&
        7|8)
            [[ $CURRENT_MODULE -le 7 ]] && module_08
            ;&
        8|9)
            [[ $CURRENT_MODULE -le 8 ]] && module_09
            ;&
        9|10)
            [[ $CURRENT_MODULE -le 9 ]] && module_10
            ;&
        10|11)
            [[ $CURRENT_MODULE -le 10 ]] && module_11
            ;&
        11|12)
            [[ $CURRENT_MODULE -le 11 ]] && module_12
            ;;
    esac

    # Show final results
    show_final_results
}

# Run the program
main
