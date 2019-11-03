/ Socket syscalls examples /
/ Based on Beej's Guide to Network Programming /

/ Socket syscalls /
∇ SOCKET C6 3 SYS ∇     ∇ TSOC 0 1 2 SOCKET ∇
∇ LISTEN C9 2 SYS ∇     ∇ LIS 0 ↕ LISTEN ↓ ∇
∇ BIND C8 3 SYS ∇       ∇ BIN 10 ↕ ⌽ BIND ↓ ∇
∇ CONNECT CB 3 SYS ∇    ∇ CON 10 ↕ ⌽ CONNECT ↓ ∇
∇ ACCEPT CA 3 SYS ∇     ∇ ACC 0 0 ⌽ ACCEPT ∇

/ PORT builds port struct /
/ e.g. FA0 PORT leaves port struct for port 4000 on the stack /
∇ PORT 10⌽ 10 << 2 + ∇ / n→n /

/ TCP client and server /
/ Try running in separate JonesForth processes as e.g. FA0 PORT SERVER and FA0 PORT CLIENT /

∇ SERVER / n→ /
        H ! TSOC ↑ ↑ H BIN LIS
        ( ↑ ACC S" Weasel attack!" ↕ ⌽ ⍈ ." Accepted" CR ∥) ∇

∇ CLIENT / n→ /
        H ! TSOC ↑ H CON
        10 H ⌽ ⍇ H ↕ TELL ∇

/ UDP talker and listener /
∇ USOC 0 2 2 SOCKET ∇
∇ SENDTO CE 6 SYS ∇
∇ RECVFROM CF 6 SYS ∇
VAR &10
10 &10 !

∇ LISTENER
H ! USOC ↑ H BIN
>R &10 H 0 10 H 20 + R> RECVFROM
H 20 + ↕ TELL ∇

∇ TALKER
H ! USOC >R 10 H 0 S" Weasel" ↕ R> SENDTO ∇
