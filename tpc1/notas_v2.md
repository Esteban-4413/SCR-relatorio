# SCR TP1 (G21): Parte 1, texto final (v2, nova topologia)

Legenda: ✅ fechado · ⚠️ confirmar · 🔧 falta captura

## Estado

| Pergunta | Estado | Evidência |
|---|---|---|
| 1 a 5 | ✅ | capturas HTTP (já fechadas) |
| 6a, 6b, 6c | ✅ | `prob2.png`, `probBn7.png` |
| 7 a 11 | ✅ | `prob31.png` a `prob35.png` |
| 14 | ✅ | `prob31.png` (+ nota sobre o 2.º par ARP) |
| 15 (ARP) | ✅ | `prob32.png`, `prob33.png` |
| 15 (colisão), Depto B | ✅ | `probCb.png` |
| 15 (colisão), Depto A | 🔧 | `probCa.png` só mostra o terminal de n1 |
| 16 | ✅ | MAC de `probBn7.png` + esquema com as portas |

> **Atenção:** esta é a **nova topologia**. Os IP e MAC dos hosts de A mudaram em relação à anterior (agora n5 é `10.0.0.21` / `…:01`). Não misturar com os screenshots antigos (`ping1`, `arpn51`, `ping2`, `dualping`, `topologiaFixed`, `tcpdump1/2`, `arpFilter1-4`).

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
- **Origem:** `d4:7f:35:16:e2:9f` (`Cisco_16:e2:9f`, bit LG 0: endereço de fábrica). É o *gateway*/router da rede local, que entrega ao computador a resposta do servidor.
- **Destino:** `1e:6c:c2:c2:3a:2c`, o computador do aluno (`172.26.193.235`), com bit LG 1 (endereço privado, o mesmo que era a origem do pedido).
- **Justificação:** são os endereços do pedido com os papéis trocados (*hex dump*: bytes 0-5 = `1e 6c c2 c2 3a 2c`, bytes 6-11 = `d4 7f 35 16 e2 9f`). Os IP mantêm-se fim-a-fim (`193.136.9.240` → `172.26.193.235`), mas os MAC são os do **último salto**: o servidor está noutra rede, logo o MAC de origem não é o dele. O TTL de 61 (`0x3d`), inferior ao valor inicial típico de 64, é coerente com a travessia de routers.

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

**Topologia usada (CORE):**

![[topololgia2.png]]

| Nó | Papel | IP | MAC |
|---|---|---|---|
| n4 | PC (Depto A) | 10.0.0.20 | `00:00:00:aa:00:00` |
| n5 | servidor (Depto A) | 10.0.0.21 | `00:00:00:aa:00:01` |
| n3 | PC (Depto A) | 10.0.0.22 | `00:00:00:aa:00:02` |
| n2 | PC (Depto A) | 10.0.0.23 | `00:00:00:aa:00:03` |
| n1 | PC (Depto A) | 10.0.0.24 | `00:00:00:aa:00:04` |
| n6 | switch (Depto A) | (L2) | |
| n7 (RA) | router | 10.0.0.1 (`eth0`), 10.0.1.1 (`eth1`) | `eth0`: `00:00:00:aa:00:05` |
| n8 (RB) | router | 10.0.1.2, 10.0.2.1, 10.0.3.1 | 10.0.1.2: `00:00:00:aa:00:07` |
| n9 (RC) | router | 10.0.2.2 | |
| n10 | hub (Depto B) | (L1) | |
| n13, n12, n11 | PCs (Depto B) | 10.0.3.20, .21, .22 | n12: `…:0c`; n11: `…:0d` |

⚠️ A associação n1…n4 ↔ IP vem das legendas da topologia; confirma com `ip -br a` (só n5, n11 e n12 estão confirmados pelas capturas).

### Pergunta 6
> Abra uma consola no host onde efetuou o ping. Observe o conteúdo da tabela ARP com o comando `arp`.

![[prob2.png]]

No host n5, depois de apagar a cache (`arp -d 10.0.0.1`), a tabela fica vazia. Após `ping -c 1 10.0.3.20` e `ping -c 1 10.0.3.21`, passa a ter uma única entrada, a do *gateway* `10.0.0.1`.

- **a)** Colunas (`man arp`): *Address* (IP do vizinho), *HWtype* (tipo de ligação, `ether`), *HWaddress* (MAC resolvido), *Flags Mask* (`C` = entrada completa/dinâmica; `M` = permanente) e *Iface* (interface de rede). Só aparece `10.0.0.1` porque os destinos dos pings estão noutra rede: o host só precisa do MAC do próximo salto.
- **b)** O router **n7 (RA)**: na LAN do Depto A tem cinco vizinhos diretos (n1 a n5) e ainda o n8 na ligação ponto-a-ponto, ou seja, **6 entradas**. O n8 teria 5 (n7, n9 e os três PCs de B), o n9 apenas 1, e cada host apenas 1 (o seu *gateway*). O switch e o hub, sendo equipamentos de nível 1/2, não mantêm tabela ARP.
- **c)** Para completar a tabela de n7, fez-se `ping` a todos os hosts da sua LAN e a n8, de modo a gerar um pedido ARP para cada vizinho:

  ```bash
  for i in 20 21 22 23 24; do ping -c 1 10.0.0.$i; done
  ping -c 1 10.0.1.2
  arp
  ```

  ![[probBn7.png]]


  | Address | HWaddress | Iface |
  |---|---|---|
  | 10.0.0.20 | `00:00:00:aa:00:00` | eth0 |
  | 10.0.0.21 | `00:00:00:aa:00:01` | eth0 |
  | 10.0.0.22 | `00:00:00:aa:00:02` | eth0 |
  | 10.0.0.23 | `00:00:00:aa:00:03` | eth0 |
  | 10.0.0.24 | `00:00:00:aa:00:04` | eth0 |
  | 10.0.1.2 | `00:00:00:aa:00:07` | eth1 |

### Pergunta 7
> Qual é o valor hexadecimal dos endereços origem e destino na trama Ethernet que contém o ARP Request? Como interpreta e justifica o endereço destino usado?

![[prob31.png]]
![[prob32.png]]

**Resposta (trama 305).** Origem: `00:00:00:aa:00:01` (n5). Destino: `ff:ff:ff:ff:ff:ff` (*broadcast*).

O n5 conhece o IP que quer alcançar (o *gateway* `10.0.0.1`), mas não o MAC correspondente, que é precisamente o que pretende descobrir. Por isso o pedido é enviado em *broadcast*, para que todos os nós da rede local o recebam e só o dono do IP responda.

### Pergunta 8
> Qual o valor hexadecimal no campo Tipo da trama Ethernet? O que indica?

**Resposta.** `0x0806`. Indica que o *payload* da trama é uma mensagem **ARP**.

### Pergunta 9
> Observando a mensagem ARP, como pode saber que se trata efetivamente de um pedido ARP? Identifique o tipo de endereços contidos na mensagem ARP.

**Resposta.** O campo *Opcode* tem o valor **1** (*request*). A mensagem contém endereços de hardware, neste caso Ethernet/MAC (*Hardware type* 1, 6 bytes ou 48 bits), e endereços de protocolo, neste caso IPv4 (*Protocol type* `0x0800`, 4 bytes ou 32 bits).

### Pergunta 10
> Explicite, em linguagem comum, que tipo de pedido ou pergunta é feita pelo host de origem à rede?

**Resposta.** *«Quem tem o endereço IP 10.0.0.1? Respondam a 10.0.0.21 (MAC `00:00:00:aa:00:01`).»* O campo *Target MAC* vai a zeros (`00:00:00:00:00:00`) porque é o que se pretende descobrir.

### Pergunta 11
> Localize a mensagem ARP que é a resposta ao pedido ARP efetuado.

![[prob33.png]]

**Resposta (trama 306, `10.0.0.1 is at 00:00:00:aa:00:05`).**
- **a)** *Opcode* = **2** (*reply*): especifica que a mensagem é uma resposta ARP.
- **b)** A resposta está no campo ***Sender MAC address*** (bytes 22-27 da trama): `00:00:00:aa:00:05`, associado ao *Sender IP* `10.0.0.1`. O *Target MAC/IP* são os de quem perguntou (`…:01` / `10.0.0.21`).
- **c)** A resposta é enviada em **unicast** (destino `00:00:00:aa:00:01`) porque o MAC do requerente já é conhecido: veio no campo *Sender MAC* do pedido. Não é preciso difundir.

### Pergunta 14
> Verifique se o ping feito ao segundo PC originou pacotes ARP e justifique a situação observada.

**Resposta.** Não. O n5 só enviou **um** pedido ARP (trama 305, para o *gateway*). Os dois destinos (`10.0.3.20` e `10.0.3.21`) estão fora da LAN, pelo que o ARP serve apenas para obter o MAC do *gateway* (`10.0.0.1`), que fica guardado na cache (`arp` mostra a entrada com a *flag* `C`). O segundo `ping` reutiliza essa entrada, sem novo pedido ARP.

**Observação.** A captura mostra ainda um segundo par ARP (tramas 311/312, ≈ 5 s depois), mas é o **router n7** que pergunta em *unicast* o MAC de n5 (`Who has 10.0.0.21? Tell 10.0.0.1`) e o n5 que responde. É a revalidação da entrada da cache ARP feita pelo núcleo Linux, e não um pedido de n5 por causa do 2.º ping. ⚠️ Para o demonstrar, mudar o filtro para `arp || icmp` e confirmar que n5 não envia nenhum pedido ARP depois da trama 305.

### Pergunta 15 (ARP)
> Identifique na mensagem ARP os campos que permitem definir o tipo e o tamanho dos endereços das camadas de rede e de ligação lógica que se pretendem mapear. Justifique os valores apresentados nesses campos.

**Resposta** (frames 305 e 306):

| Campo | Valor | Significado |
|---|---|---|
| *Hardware type* | 1 | Ethernet (camada de ligação) |
| *Protocol type* | `0x0800` | IPv4 (camada de rede) |
| *Hardware size* | 6 | endereço MAC = 6 bytes |
| *Protocol size* | 4 | endereço IPv4 = 4 bytes |

---

## 5. Domínios de colisão

### Pergunta 15 (colisão)
> Através da opção tcpdump, verifique e compare como flui o tráfego nas diversas interfaces dos vários dispositivos no departamento A (LAN comutada) e no departamento B (LAN partilhada) quando gera tráfego intra-departamento.

**Departamento B (hub).** O n11 fez `ping` ao n12 (`10.0.3.21`) e o `tcpdump -n -e -i eth0 icmp or arp` correu no n13, que **não participa** na comunicação:

![[probCb.png]]

O n13 vê tudo: o ARP Request em *broadcast* (`00:00:00:aa:00:0d > ff:ff:ff:ff:ff:ff`), o ARP Reply em *unicast* (`…:0c > …:0d`) e os ICMP *echo request/reply* entre n11 e n12, ou seja, tramas que não lhe são dirigidas.

**Departamento A (switch).** 🔧 **[captura a refazer: n1 → n2 (`ping -c 1 10.0.0.23`), com `tcpdump` visível em n3, n4 e n5]**

![[probCa.png]]

Resultado esperado: cada espectador mostra apenas o ARP Request em *broadcast* (`Who has 10.0.0.23? Tell 10.0.0.24`), e nem o ARP Reply (*unicast*) nem os ICMP.

**Conclusão.**
- **Departamento B (hub):** o hub opera repetindo o sinal elétrico recebido por todas as suas portas, por isso todos os hosts veem todas as tramas (mesmo as dirigidas a outro). Partilham a mesma largura de banda e encontram-se no mesmo domínio de colisão.
- **Departamento A (switch):** o switch constrói uma tabela de comutação que associa MAC a portas. Depois da aprendizagem, as tramas *unicast* são encaminhadas apenas para a porta do destino, e os outros hosts não veem esse tráfego. Cada porta é um domínio de colisão distinto.
- **Exceção no switch:** os pacotes de *broadcast* (como os pedidos ARP) e os destinados a MAC ainda desconhecidos são difundidos por todas as portas (exceto a de origem).
- Em suma, o switch divide e isola os domínios de colisão; o hub não o faz.

### Pergunta 16
> Apresente a tabela de comutação completa do switch do departamento A.

Os MAC vêm da tabela ARP de n7 (`probBn7.png`) e as portas foram atribuídas à escolha (P1 a P6, indicadas no esquema):

| Endereço MAC        | Porta | Equipamento                       |
| ------------------- | ----- | --------------------------------- |
| `00:00:00:aa:00:04` | P1    | n1                                |
| `00:00:00:aa:00:03` | P2    | n2                                |
| `00:00:00:aa:00:02` | P3    | n3                                |
| `00:00:00:aa:00:00` | P4    | n4                                |
| `00:00:00:aa:00:01` | P5    | n5 (servidor)                     |
| `00:00:00:aa:00:05` | P6    | n7 (`eth0`, ligação ao router RA) |

🔧 Esquema: desenhar o switch n6 com as portas P1 a P6 a ligar a cada equipamento (pode ser sobre a figura da topologia).

---

# Para a versão final (Typst)

- Usar **só** os screenshots novos. Os antigos mostram outra topologia (outros IP/MAC) e alguns têm o `arp -d -a` que não apagava nada.
- **Recortar** os screenshots para a janela do Wireshark ou do terminal (sem o fundo do ecrã).
- Retirar o que é instrução para vocês (⚠️, 🔧, *"confirma…"*).
- Nomes dos ficheiros: `topololgia2.png` tem uma gralha; pode ficar, desde que o nome coincida no código.
