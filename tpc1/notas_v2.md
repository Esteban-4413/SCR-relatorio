# SCR TP1 (G21): Parte 1, notas finais

Legenda: ✅ fechado · 🔧 falta captura/experiência no CORE · ⚠️ confirmar

## Estado

| Pergunta | Estado | Nota |
|---|---|---|
| 1, 2, 3 | ✅ | |
| 4, 5 | ✅ | confirmado com o screenshot da trama 11367 |
| 6a | ✅ | colunas visíveis nos screenshots |
| 6b | ✅ (texto) | usa os nós reais: **n7** |
| 6c | 🔧 | tabela ARP completa de n7 |
| 7, 8, 9, 10, 11 | 🔧 | falta captura Wireshark do ARP Request/Reply |
| 14, 15 (ARP) | 🔧 | idem (precisa do `arp` com a cache limpa a sério) |
| 15 (colisão) | 🔧 | refazer: os testes feitos são inter-departamento |
| 16 | 🔧 | MAC dos hosts de A (saem da tabela de n7) |

---

## O que falta fazer no CORE (≈ 30-40 min)

> **Problema nas capturas atuais:** `arp -d -a` **não apagou nada**, só listou a tabela (um `delete` bem-sucedido não imprime nada, e a entrada `10.0.0.1` continuou lá). A entrada que importa é a do *gateway* `10.0.0.1`. Sem a apagar, o `ping` pode nem gerar ARP.

### A) ARP Request/Reply (P7-P11, P14, P15) em **n5**
1. No terminal de n5: `export DISPLAY=:0.0` e `wireshark &` → capturar em `eth0`.
2. No terminal de n5:
   ```bash
   arp -d 10.0.0.1      # ou: ip neigh flush all
   arp                  # tem de aparecer vazia
   ping -c 1 10.0.3.20  # 1.º ping → gera ARP
   ping -c 1 10.0.3.21  # 2.º ping → não deve gerar ARP
   arp                  # só a entrada do gateway
   ```
3. Parar a captura, filtro `arp`, e guardar screenshots de: lista (deve haver 2 tramas), **Ethernet II** do Request (endereços + Type), **Address Resolution Protocol** do Request expandido, e o mesmo para o Reply.

### B) Tabela ARP de n7 (P6c) e MAC do switch (P16)
No terminal de **n7**:
```bash
for i in 20 21 22 23 24; do ping -c 1 10.0.0.$i; done
ping -c 1 10.0.1.2
arp
```
Esperam-se **6 entradas** (n2, n1, n3, n4, n5 por `eth0` + n8 por `eth1`). O mesmo ecrã dá-te os MAC para a P16.

### C) tcpdump (P15 colisão): tem de ser tráfego **intra**-departamento
- **Depto A:** em n3, n4 e n5 correr `tcpdump -n -e -i eth0 icmp or arp`. Em n1: `ip neigh flush all` e depois `ping -c 5 10.0.0.20` (n1 → n2).
- **Depto B:** em n12 e n13 correr o mesmo `tcpdump`, **antes** de começar o ping. Em n11: `ping -c 5 10.0.3.21` (n11 → n12).
- ⚠️ Se em B o n13 **não** vir o ICMP entre n11 e n12, o `n10` não está a comportar-se como hub (no canvas, n6 e n10 têm o mesmo ícone). Verifica o tipo do nó e, se for preciso, troca por um **Hub**.
- O filtro `icmp or arp` evita confundir com os *hellos* OSPF (`224.0.0.5`), que aparecem em qualquer LAN.

---

# Texto final

## 3. Captura e análise de tramas Ethernet

### Pergunta 1
> Anote os endereços Ethernet (ou MAC) de origem e de destino da trama capturada com o pedido HTTP. Identifique a que sistemas se referem. Justifique.

![[ethernet.png]]

**Resposta.**
- **Origem:** `1e:6c:c2:c2:3a:2c`. É a interface Wi-Fi (`en0`) do computador onde se fez a captura (IP `172.26.193.235`). O bit LG vale 1 (*Locally administered address, this is NOT the factory default*), ou seja, não é o endereço de fábrica da placa, mas um endereço privado/aleatório, o que é compatível com o recurso de endereço Wi-Fi privado do macOS.
- **Destino:** `d4:7f:35:16:e2:9f`, identificado pelo Wireshark como `Cisco_16:e2:9f` (bit LG 0, endereço de fábrica; bit IG 0, *unicast*). É o equipamento de **primeiro salto** (*gateway*/router, ou AP da Eduroam) e **não** o servidor web.
- **Justificação:** o IP destino (`193.136.9.240`, marco.uminho.pt) pertence a outra rede, por isso a trama é entregue ao *gateway*, que a encaminha. Os MAC só têm significado na ligação local (mudam em cada salto), enquanto os IP são fim-a-fim.

### Pergunta 2
> Analisando os campos do cabeçalho da trama capturada, diga, justificando, qual o protocolo encapsulado nessa trama.

**Resposta.** O protocolo encapsulado é o **IPv4**. O campo *Type* do cabeçalho Ethernet vale `0x0800` (bytes 12-13 da trama, `08 00`, linha `0000` do *hex dump*), valor que identifica IPv4. Confirma-se no byte seguinte, `45`: versão 4 e cabeçalho de 5 palavras de 32 bits (20 bytes).

### Pergunta 3
> Quantos bytes são usados desde o início da trama até ao caractere ASCII "G" do método HTTP GET? Calcule e indique, em percentagem, a sobrecarga (*overhead*) introduzida pela pilha protocolar no envio do HTTP GET (considere os bytes ocupados pela camada física e pelo FCS, indicados na Figura 1).

![[IP.png]]
![[TCP.png]]
![[GET.png]]

**Resposta.**

| Camada | Bytes | Evidência |
|---|---|---|
| Ethernet II (cabeçalho) | 14 | 6 + 6 + 2 |
| IPv4 | 20 | *Header Length: 20 bytes (5)* |
| TCP | 32 | *Header Length: 32 bytes (8)* (20 + 12 de opções: NOP, NOP, Timestamps) |
| **Total até ao "G"** | **66** | |

O "G" (`47`) está no *offset* `0x42` = 66 (linha `0040` do *hex dump*: `cd 1d 47 45 54`), pelo que são usados **66 bytes** antes do "G" (74 se se contar o preâmbulo + SFD de 8 bytes).

**Sobrecarga:**
- *Payload* HTTP = **415 B** (confere: 66 + 415 = 481 B, o tamanho da trama).
- Camada física: preâmbulo 7 B + SFD 1 B = **8 B**; FCS = **4 B**.
- Tamanho total enviado: 8 + 481 + 4 = **493 B**.
- Bytes de sobrecarga: 8 + 66 + 4 = **78 B**.

> **Sobrecarga = 78 / 493 ≈ 15,8 %** (sobrecarga sobre o total enviado)

### Pergunta 4
> Quais são os endereços Ethernet da origem e destino? A que sistemas de rede correspondem? Justifique. *(trama com o primeiro byte da resposta HTTP)*

![[ethernet113667.png]]

**Resposta (trama 11367).**
- **Origem:** `d4:7f:35:16:e2:9f` (`Cisco_16:e2:9f`, bit LG 0: endereço de fábrica). É o *gateway*/router da rede local, que entrega à máquina a resposta do servidor.
- **Destino:** `1e:6c:c2:c2:3a:2c`, o computador do aluno (`172.26.193.235`), com bit LG 1 (endereço privado, o mesmo que era a origem do pedido).
- **Justificação:** os endereços são exatamente os do pedido com os papéis trocados (*hex dump*: bytes 0-5 = `1e 6c c2 c2 3a 2c`, bytes 6-11 = `d4 7f 35 16 e2 9f`). Os IP mantêm-se fim-a-fim (`193.136.9.240` → `172.26.193.235`), mas os MAC são os do **último salto**: o servidor está noutra rede, logo o MAC de origem não é o dele. O TTL de 61 (`0x3d`) na resposta, inferior ao valor inicial típico de 64, é coerente com a travessia de routers.

### Pergunta 5
> Atendendo ao conceito de desencapsulamento protocolar, identifique os vários protocolos contidos na trama recebida. Represente-os num esquema por camadas.

![[hypertext-transfer-protocol.png]]

**Resposta.** Na trama 11367, de baixo para cima:

```
+---------------------------------------------------+
| Aplicação   : HTTP  (HTTP/1.1 301 Moved           |
|               Permanently; corpo text/html)       |  ← payload do TCP (539 B)
+---------------------------------------------------+
| Transporte  : TCP   (porta 80 → 64796, Ack 416)   |  ← payload do IP
+---------------------------------------------------+
| Rede        : IPv4  (193.136.9.240 →              |  ← payload da Ethernet
|                      172.26.193.235, protocolo 6) |
+---------------------------------------------------+
| Ligação     : Ethernet II (Type 0x0800)           |
+---------------------------------------------------+
```

Durante o desencapsulamento, cada camada analisa o seu cabeçalho e passa o *payload* à camada superior: a Ethernet (campo *Type* `0x0800`) entrega os dados ao IPv4; o IPv4 (campo *Protocol* = 6) entrega-os ao TCP; e o TCP (porta de origem 80) entrega-os ao HTTP. A resposta é um redirecionamento (`301`) para `https://marco.uminho.pt/ferramentas/CORE/xubuncore.html`, e o corpo é HTML (`Content-Length: 263`). O `Ack: 416` confirma os 415 bytes do GET (415 + 1).

---

## 4. Protocolo ARP

**Topologia usada:**

![[topologia.png]]

| Dispositivo | Papel | IP |
|---|---|---|
| n1, n2, n3, n4 | PCs Depto A | 10.0.0.21, .20, .22, .23 |
| n5 | servidor Depto A | 10.0.0.24 |
| n6 | switch Depto A | (L2) |
| n7 (RA) | router | 10.0.0.1 (LAN A), 10.0.1.1 |
| n8 (RB) | router | 10.0.1.2, 10.0.2.1, 10.0.3.1 (LAN B) |
| n9 (RC) | router | 10.0.2.2 |
| n10 | hub Depto B | (L2) |
| n13, n12, n11 | PCs Depto B | 10.0.3.20, .21, .22 |

### Pergunta 6
> Abra uma consola no host onde efetuou o ping. Observe o conteúdo da tabela ARP com o comando `arp`.

![[ping1.png]]
![[arpn51.png]]
![[dualping.png]]

- **a)** Colunas: *Address* (IP do vizinho), *HWtype* (tipo de ligação, `ether`), *HWaddress* (MAC resolvido), *Flags Mask* (`C` = entrada completa/dinâmica; `M` = permanente) e *Iface* (interface de rede). Na tabela de n5 só aparece `10.0.0.1` (o *gateway*), porque os pings iam para a rede B: o host só precisa do MAC do próximo salto.
- **b)** O router **n7 (RA)**: tem na LAN A cinco vizinhos diretos (n1 a n5) e ainda n8 na ligação ponto-a-ponto, ou seja, até **6 entradas**. O n8 teria 5 (n7, n9 e três PCs de B), o n9 apenas 1 e cada host só 1 (o seu *gateway*). Switch e hub, sendo L2, não mantêm tabela ARP.
- **c)** 🔧 *Procedimento:* em n7, `ping` a cada host de A (`10.0.0.20` a `.24`) e a n8 (`10.0.1.2`), e depois `arp`. **[colar aqui o screenshot da tabela completa de n7]**

### Pergunta 7
> Qual é o valor hexadecimal dos endereços origem e destino na trama Ethernet que contém o ARP Request? Como interpreta e justifica o endereço destino usado?

🔧 ![[arp-request-ethernet.png]]

- **Origem:** MAC de n5 **[preencher: `00:00:00:aa:00:__`]**. **Destino:** `ff:ff:ff:ff:ff:ff` (*broadcast*).
- **Justificação:** n5 conhece o IP do destino (`10.0.0.1`) mas não o MAC, que é o que quer descobrir. Por isso envia a todos os nós da rede local e só o dono do IP responde.

### Pergunta 8
> Qual o valor hexadecimal no campo Tipo da trama Ethernet? O que indica?

- `0x0806`: indica que o *payload* da trama é uma mensagem **ARP**. ⚠️ Confirma na captura.

### Pergunta 9
> Observando a mensagem ARP, como pode saber que se trata efetivamente de um pedido ARP? Identifique o tipo de endereços contidos na mensagem ARP.

- A mensagem identifica-se como pedido através do campo *Opcode*, que tem o valor 1 (*request*).
- Contém endereços de hardware, neste caso Ethernet/MAC (48 bits, 6 bytes), e endereços de protocolo, neste caso IPv4 (32 bits, 4 bytes).

### Pergunta 10
> Explicite, em linguagem comum, que tipo de pedido ou pergunta é feita pelo host de origem à rede?

- Traduz-se por *"Quem tem o endereço IP 10.0.0.1? Digam-me o vosso MAC; o meu IP é 10.0.0.24 e o meu MAC é …"*. O campo *Target MAC* vai a zeros (`00:00:00:00:00:00`) porque é o que se pretende descobrir. ⚠️ Confirma os IP na captura.

### Pergunta 11
> Localize a mensagem ARP que é a resposta ao pedido ARP efetuado.

🔧 ![[arp-reply.png]]

- **a)** *Opcode* = 2 (*reply*): indica que é uma resposta ARP.
- **b)** A resposta está no campo **Sender MAC address** da mensagem de resposta (o MAC de quem tinha o IP perguntado, aqui `00:00:00:aa:00:05` segundo a tabela ARP de n5).
- **c)** A resposta é **unicast**, porque o MAC do requerente já é conhecido (veio no *Sender MAC* do pedido), não sendo necessário difundir.

### Pergunta 14
> Verifique se o ping feito ao segundo PC originou pacotes ARP e justifique a situação observada.

🔧 **[captura Wireshark com o filtro `arp` a mostrar um único par Request/Reply]**

- Não originou. Ambos os pings (`10.0.3.20` e `10.0.3.21`) têm destino fora da LAN A, por isso o ARP é feito apenas para o MAC do *gateway* (`10.0.0.1`). Depois do primeiro ping essa associação fica na cache ARP (`arp` mostra só `10.0.0.1`) e o segundo ping reutiliza-a.

### Pergunta 15 (ARP)
> Identifique na mensagem ARP os campos que permitem definir o tipo e o tamanho dos endereços das camadas de rede e de ligação lógica que se pretendem mapear. Justifique os valores apresentados nesses campos.

| Campo | Valor | Significado |
|---|---|---|
| Hardware type | 1 | Ethernet |
| Protocol type | `0x0800` | IPv4 |
| Hardware size | 6 | MAC = 6 bytes |
| Protocol size | 4 | IPv4 = 4 bytes |

---

## 5. Domínios de colisão

### Pergunta 15 (colisão)
> Através da opção tcpdump, verifique e compare como flui o tráfego nas diversas interfaces dos vários dispositivos no departamento A (LAN comutada) e no departamento B (LAN partilhada) quando gera tráfego intra-departamento.

🔧 **Depto A** (n1 → n2; tcpdump em n3, n4, n5): ![[tcpdump-A.png]]
🔧 **Depto B** (n11 → n12; tcpdump em n12, n13): ![[tcpdump-B.png]]

> As capturas atuais (`tcpdump1/2`) usam pings **inter**-departamento (n3 → 10.0.3.22 e n11 → 10.0.0.23), e em B o n12 só mostra *hellos* OSPF. Refazer como descrito no ponto C.

**Conclusão** (confirmar com as novas capturas):
- **Departamento B (hub):** o hub repete o sinal elétrico por todas as portas, por isso todos os hosts veem todas as tramas. Partilham a mesma largura de banda e o mesmo domínio de colisão.
- **Departamento A (switch):** o switch constrói uma tabela de comutação MAC → porta. Depois de aprender, as tramas *unicast* só são encaminhadas para a porta do destino, e os restantes hosts não veem esse tráfego. Cada porta é um domínio de colisão distinto.
- **Exceção:** o primeiro pacote para um destino desconhecido (e os *broadcasts*, como os pedidos ARP) é difundido por todas as portas (exceto a de origem).
- Em suma, o switch divide e isola os domínios de colisão; o hub não.

### Pergunta 16
> Apresente a tabela de comutação completa do switch do departamento A.

🔧 Os MAC saem da tabela ARP de n7 (ponto B) e do `arp` de n5 (`00:00:00:aa:00:05` = interface de n7 ligada ao switch). Portas à escolha, desenhadas no esquema.

| MAC | Porta |
|---|---|
| (n1) | P1 |
| (n2) | P2 |
| (n3) | P3 |
| (n4) | P4 |
| (n5, servidor) | P5 |
| `00:00:00:aa:00:05` (n7, interface `eth0`) | P6 |

---

# Para a versão final (Typst)

- O enunciado pede **só**: título e identificação do grupo, "Questões e Respostas" (transcrição + resposta) e "Conclusões". **Sem abstract.** Ficheiro: `SCR-TP1-G21.pdf` (se o grupo for o G21).
- **Recortar os screenshots** para a janela do Wireshark/terminal (sem o fundo do ecrã) e ocupar a largura da página, porque no PDF atual estão ilegíveis.
- Retirar tudo o que é instrução para vocês (*"Justifica…"*, *"faz ping…"*, *"confirma…"*, *"Resposta esperada"*) e os parágrafos duplicados.
- Trocar as legendas provisórias (*"whatever"*).
