; ###########1#########################################################
; --- 用户可配置 ---
; LongPressThreshold: 按下多长时间算长按 (单位: 秒, 如 0.2)
; MouseMoveStep: 鼠标移动初始步长 (单位: 像素, 如 15)
; MouseAcceleration: 鼠标移动加速倍数 (如 1.15)
; MouseMaxSpeed: 鼠标移动最大速度 (单位: 像素, 如 80))
;
; --- 核心功能 ---
; Alt + O             : 鼠标左键单击
; Alt + A             : 鼠标右键单击
;
; Alt + Shift + Q     : 关闭当前窗口
; Alt + Win+ J/K (按住)    : 持续上/下滚动
; Alt + C             : 移动鼠标到窗口中央
; Alt + T             : 移动鼠标到屏幕中央
;
; --- 鼠标移动 ---
; Ctrl + Alt + hjkl   : 移动鼠标上下左右 (按住加速)
;   > h = 左, j = 下, k = 上, l = 右
; Alt + gg (双击g)    : 移动鼠标到当前窗口最上方
; Alt + G             : 移动鼠标到当前窗口最下方
; Alt + 0             : 移动鼠标到当前窗口中间最左边
; Alt + $             : 移动鼠标到当前窗口中间最右边
; --- 窗口移动模式 ---
; Alt + M             : 进入 / 退出移动模式
;   > 方向键          : 移动窗口
;   > Enter / Esc     : 确认并退出模式
;
; --- 窗口调整大小模式 ---
; Alt + R             : 进入 / 退出调整大小模式
;   > 方向键          : 调整窗口大小
;   > Enter / Esc     : 确认并退出模式
;
; #####################################################################

; 脚本自动请求管理员权限
if not A_IsAdmin
{
    try
    {
        if A_IsCompiled
            DllCall("Shell32\ShellExecute", "ptr", 0, "str", "RunAs", "str", A_ScriptFullPath, "ptr", 0, "ptr", 0, "int", 1)
        else
            DllCall("Shell32\ShellExecute", "ptr", 0, "str", "RunAs", "str", A_AhkPath, "str", '"' A_ScriptFullPath '"', "ptr", 0, "int", 1)
    }
    ExitApp
}
#SingleInstance force
SendMode "Input"

; === 全局变量 ===
global MoveStep := 30
global ResizeStep := 30
global MouseMoveStep := 15
global MouseAcceleration := 1.15  ; 加速倍数
global MouseMaxSpeed := 80       ; 最大移动速度
global LongPressThreshold := 0.2
global inMoveMode := false
global inResizeMode := false

; 鼠标移动状态变量
global mouseMoving := {up: false, down: false, left: false, right: false}
global currentMouseSpeed := {up: 0, down: 0, left: 0, right: 0}


; === 核心热键 (无条件) ===

; --- 左键单击 ---
$!o::Click("left")

RemoveToolTip() => ToolTip()

; --- 其他核心功能 ---
!a::Click("right")
!+q::WinClose("A")

; --- 鼠标移动快捷键 (支持加速) ---

; Ctrl+Alt+hjkl 移动鼠标 - 按下时开始移动
$^!k:: ; 上 (k)
{
    global mouseMoving, currentMouseSpeed, MouseMoveStep
    mouseMoving.up := true
    currentMouseSpeed.up := MouseMoveStep
    StartMouseMove("up")
}

$^!j:: ; 下 (j)
{
    global mouseMoving, currentMouseSpeed, MouseMoveStep
    mouseMoving.down := true
    currentMouseSpeed.down := MouseMoveStep
    StartMouseMove("down")
}

$^!h:: ; 左 (h)
{
    global mouseMoving, currentMouseSpeed, MouseMoveStep
    mouseMoving.left := true
    currentMouseSpeed.left := MouseMoveStep
    StartMouseMove("left")
}

$^!l:: ; 右 (l)
{
    global mouseMoving, currentMouseSpeed, MouseMoveStep
    mouseMoving.right := true
    currentMouseSpeed.right := MouseMoveStep
    StartMouseMove("right")
}

; 按键释放时停止移动
$^!k up:: ; 上 (k) 释放
{
    global mouseMoving
    mouseMoving.up := false
}

$^!j up:: ; 下 (j) 释放
{
    global mouseMoving
    mouseMoving.down := false
}

$^!h up:: ; 左 (h) 释放
{
    global mouseMoving
    mouseMoving.left := false
}

$^!l up:: ; 右 (l) 释放
{
    global mouseMoving
    mouseMoving.right := false
}

; Alt+gg - 移动鼠标到当前窗口最上方
!g::
{
    ; 检测是否是双击 g (实现 gg 效果)
    static lastGTime := 0
    currentTime := A_TickCount
    
    if (currentTime - lastGTime < 500) ; 500ms 内双击
    {
        ; 移动到窗口最上方，稍微往下偏移
        WinGetPos(&winX, &winY, &winW, &winH, "A")
        MouseMove(winX + winW / 2, winY + 30) ; 窗口顶部中央，往下偏移30像素
        ToolTip("Mouse moved to window top")
        SetTimer(RemoveToolTip, -1000)
        lastGTime := 0 ; 重置时间
    }
    else
    {
        lastGTime := currentTime
    }
}

; Alt+G - 移动鼠标到当前窗口最下方
!+g::
{
    WinGetPos(&winX, &winY, &winW, &winH, "A")
    MouseMove(winX + winW / 2, winY + winH - 30) ; 窗口底部中央，往上偏移30像素
    ToolTip("Mouse moved to window bottom")
    SetTimer(RemoveToolTip, -1000)
}

; Alt+0 - 悬停触发侧边栏
; Alt+0 - 移动鼠标到屏幕左侧 (用于侧边栏)
!0::
{
    ; 移动到屏幕最左侧，垂直居中
    MouseMove(1, A_ScreenHeight / 2, 0) ; 先移动到最左边触发
    Sleep 50 ; 短暂等待，确保侧边栏有时间响应
    MouseMove(10, A_ScreenHeight / 2, 0) ; 再移动到目标位置
}

; Alt+$ - 移动鼠标到当前窗口中间最右边
!+4:: ; Alt+Shift+4 对应 Alt+$
{
    WinGetPos(&winX, &winY, &winW, &winH, "A")
    MouseMove(winX + winW - 30, winY + winH / 2) ; 窗口右边中央，往左偏移30像素
    ToolTip("Mouse moved to window right")
    SetTimer(RemoveToolTip, -1000)
}
; === 修改滚动热键为 Alt+Win+J/K (更可靠的实现) ===
$!#j::  ; Alt+Win+J - 按下
{
    Click "WheelDown" ; 立即滚动一次
    SetTimer(ScrollDown, 100) ; 启动定时器持续滚动
}

$!#j up:: ; Alt+Win+J - 释放
{
    SetTimer(ScrollDown, 0) ; 停止滚动
}

$!#k::  ; Alt+Win+K - 按下
{
    Click "WheelUp" ; 立即滚动一次
    SetTimer(ScrollUp, 100) ; 启动定时器持续滚动
}

$!#k up:: ; Alt+Win+K - 释放
{
    SetTimer(ScrollUp, 0) ; 停止滚动
}


!c::
{
    WinGetPos(&winX, &winY, &winW, &winH, "A")
    MouseMove(winX + winW / 2, winY + winH / 2)
}


; --- 移动鼠标到屏幕中央 (使用 DllCall 提高可靠性) ---
!t::
{
    DllCall("SetCursorPos", "int", A_ScreenWidth / 2, "int", A_ScreenHeight / 2)
}


; === 模式切换热键 ===

!m::
{
    global inMoveMode, inResizeMode
    inResizeMode := false ; 确保另一个模式是关闭的
    inMoveMode := !inMoveMode ; 切换移动模式的状态 (true/false)
    if (inMoveMode)
        ToolTip("Window Move Mode Active")
    else
        ToolTip()
}

!r::
{
    global inMoveMode, inResizeMode
    inMoveMode := false ; 确保另一个模式是关闭的
    inResizeMode := !inResizeMode ; 切换调整大小模式的状态 (true/false)
    if (inResizeMode)
        ToolTip("Window Resize Mode Active")
    else
        ToolTip()
}

; === 条件性热键组 (使用 #HotIf) ===

; --- 仅在 "移动模式" 下生效的热键 ---
#HotIf inMoveMode
    Up::Move_Up()
    Down::Move_Down()
    Left::Move_Left()
    Right::Move_Right()
    Enter::ConfirmExitMode()
    Escape::ConfirmExitMode()
#HotIf

; --- 仅在 "调整大小模式" 下生效的热键 ---
#HotIf inResizeMode
    Up::Resize_Up()
    Down::Resize_Down()
    Left::Resize_Left()
    Right::Resize_Right()
    Enter::ConfirmExitMode()
    Escape::ConfirmExitMode()
#HotIf


; === 功能函数 ===

Move_Up() {
    global MoveStep
    WinGetPos(&x, &y, &w, &h, "A")
    WinMove(x, y - MoveStep, w, h, "A")
}
Move_Down() {
    global MoveStep
    WinGetPos(&x, &y, &w, &h, "A")
    WinMove(x, y + MoveStep, w, h, "A")
}
Move_Left() {
    global MoveStep
    WinGetPos(&x, &y, &w, &h, "A")
    WinMove(x - MoveStep, y, w, h, "A")
}
Move_Right() {
    global MoveStep
    WinGetPos(&x, &y, &w, &h, "A")
    WinMove(x + MoveStep, y, w, h, "A")
}

Resize_Up() {
    global ResizeStep
    WinGetPos(&x, &y, &w, &h, "A")
    WinMove(x, y, w, h - ResizeStep, "A")
}
Resize_Down() {
    global ResizeStep
    WinGetPos(&x, &y, &w, &h, "A")
    WinMove(x, y, w, h + ResizeStep, "A")
}
Resize_Left() {
    global ResizeStep
    WinGetPos(&x, &y, &w, &h, "A")
    WinMove(x, y, w - ResizeStep, h, "A")
}
Resize_Right() {
    global ResizeStep
    WinGetPos(&x, &y, &w, &h, "A")
    WinMove(x, y, w + ResizeStep, h, "A")
}

ConfirmExitMode()
{
    global inMoveMode, inResizeMode
    inMoveMode := false
    inResizeMode := false
    ToolTip("Mode Deactivated")
    SetTimer(RemoveToolTip, -1000)
}

; === 鼠标移动函数 ===

StartMouseMove(direction)
{
    ; 启动对应方向的移动定时器 (更快的刷新率)
    SetTimer(() => ContinuousMouseMove(direction), -30)
}

ContinuousMouseMove(direction)
{
    global mouseMoving, currentMouseSpeed, MouseAcceleration, MouseMaxSpeed
    
    ; 检查是否还在按住对应方向键
    if (!mouseMoving.%direction%)
        return
    
    ; 获取当前鼠标位置
    MouseGetPos(&currentX, &currentY)
    
    ; 根据方向移动鼠标
    switch direction {
        case "up":
            MouseMove(currentX, currentY - currentMouseSpeed.up, 0)
            ; 增加速度，但不超过最大值
            if (currentMouseSpeed.up < MouseMaxSpeed)
                currentMouseSpeed.up := Min(currentMouseSpeed.up * MouseAcceleration, MouseMaxSpeed)
        case "down":
            MouseMove(currentX, currentY + currentMouseSpeed.down, 0)
            if (currentMouseSpeed.down < MouseMaxSpeed)
                currentMouseSpeed.down := Min(currentMouseSpeed.down * MouseAcceleration, MouseMaxSpeed)
        case "left":
            MouseMove(currentX - currentMouseSpeed.left, currentY, 0)
            if (currentMouseSpeed.left < MouseMaxSpeed)
                currentMouseSpeed.left := Min(currentMouseSpeed.left * MouseAcceleration, MouseMaxSpeed)
        case "right":
            MouseMove(currentX + currentMouseSpeed.right, currentY, 0)
            if (currentMouseSpeed.right < MouseMaxSpeed)
                currentMouseSpeed.right := Min(currentMouseSpeed.right * MouseAcceleration, MouseMaxSpeed)
    }
    
    ; 如果还在按住，继续移动 (更快的刷新率)
    if (mouseMoving.%direction%)
        SetTimer(() => ContinuousMouseMove(direction), -30)
}






; === 滚动函数 ===
ScrollDown()
{
    Click "WheelDown"
}

ScrollUp()
{
    Click "WheelUp"
}
