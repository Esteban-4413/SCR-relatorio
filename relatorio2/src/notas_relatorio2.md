[Xubuntu core](https://marco.uminho.pt/ferramentas/CORE/xubuncore.html)
Screenshot para resolver as perguntas:


![[figura1.png]]

![[SCR-TP1-2026.pdf]]

![[capturing.png]]

![[ethernet.png]]

![[IP.png]]

![[TCP.png]]

![[hypertext-transfer-protocol.png]]

Pedido `GET`:

![[GET.png]]

Configuração do display de wireshark no terminal do core.
```bash
> export DISPLAY=:0.0 
> wireshark
```

# SCR TP1 2026: Respostas (rascunho)

## Parte 1: Ethernet e ARP

**Dados da captura (pedido HTTP, trama 11358):**
- Trama: 481 bytes · Ethernet II · IPv4 · TCP · HTTP
- MAC origem `1e:6c:c2:c2:3a:2c` · MAC destino `d4:7f:35:16:e2:9f` (`Cisco_16:e2:9f`)
- IP origem `172.26.193.235` · IP destino `193.136.9.240` (`marco.uminho.pt`)
- TCP porta origem `64796` · porta destino `80` · Seq 1 · Ack 1 · Len 415 · Flags PSH, ACK
- Resposta: trama **11367**, `HTTP/1.1 301 Moved Permanently (text/html)`, 605 bytes

### 3. Captura e análise de tramas Ethernet

#### Pergunta 1
> Anote os endereços Ethernet (ou MAC) de origem e de destino da trama capturada com o pedido HTTP. Identifique a que sistemas se referem. Justifique.

![[ethernet.png]]

**Resposta.**
- **Origem:** `1e:6c:c2:c2:3a:2c`. É a interface Wi-Fi (`en0`) do computador onde se fez a captura, o endereço IP `172.26.193.235`. O Wireshark mostra que o bit LG vale 1 (*Locally administered address, this is NOT the factory default*), ou seja, não é o endereço de fábrica da placa. É um endereço **privado/aleatório** gerado pelo sistema operativo (recurso de privacidade do macOS).
- **Destino:** `d4:7f:35:16:e2:9f`, identificado pelo Wireshark como `Cisco_16:e2:9f` (bit LG 0, endereço de fábrica; bit IG 0, *unicast*). É o equipamento de **primeiro salto** da rede (*gateway*/router, ou o AP da Eduroam) e **não** o servidor web.
- **Justificação:** o IP destino (`193.136.9.240`, marco.uminho.pt) é de outra rede. Como o servidor não está na rede local, a trama é entregue ao *gateway*, que a encaminha. Os endereços MAC têm significado apenas na ligação local (mudam em cada salto), enquanto os IP são fim-a-fim.

#### Pergunta 2
> Analisando os campos do cabeçalho da trama capturada, diga, justificando, qual o protocolo encapsulado nessa trama.

**Resposta.** O protocolo encapsulado é o **IPv4**. O campo *Type* do cabeçalho Ethernet vale `0x0800` (nos bytes 12-13 da trama, `08 00`, linha `0000` do *hex dump*), valor que identifica IPv4. Confirma-se no byte seguinte, `45`: versão 4 e comprimento de cabeçalho de 5 palavras de 32 bits (20 bytes).

#### Pergunta 3
> Quantos bytes são usados desde o início da trama até ao caractere ASCII "G" do método HTTP GET? Calcule e indique, em percentagem, a sobrecarga (*overhead*) introduzida pela pilha protocolar no envio do HTTP GET (considere os bytes ocupados pela camada física e pelo FCS, indicados na Figura 1).

![[IP.png]]
![[TCP.png]]
![[GET.png]]

**Resposta.**

| Camada | Bytes | Evidência |
|---|---|---|
| Ethernet II (cabeçalho) | 14 | 6 + 6 + 2 (*Ethernet (eth), 14 bytes*) |
| IPv4 | 20 | *Header Length: 20 bytes (5)* |
| TCP | 32 | *Header Length: 32 bytes (8)* (20 + 12 de opções: NOP, NOP, Timestamps) |
| **Total até ao "G"** | **66** | |

O "G" (`47`) está no *offset* `0x42` = 66 da trama (linha `0040` do *hex dump*: `cd 1d 47 45 54`), por isso são usados **66 bytes** antes do "G" (74 se contares o preâmbulo + SFD de 8 bytes).

**Sobrecarga:**
- *Payload* HTTP (TCP payload) = **415 B**. Confere: 66 + 415 = 481 B (tamanho da trama).
- Camada física: preâmbulo 7 B + SFD 1 B = **8 B**; FCS = **4 B**.
- Tamanho total enviado: 8 + 481 + 4 = **493 B**
- Sobrecarga = 8 + 66 + 4 = **78 B**

> **Sobrecarga = 78 / 493 $\approx$ 15,8 %**

(Sem contar camada física nem FCS seria 66/481 ≈ 13,7 %. Refere ambos se quiseres, mas o enunciado pede o primeiro.)

#### Pergunta 4
> Quais são os endereços Ethernet da origem e destino? A que sistemas de rede correspondem? Justifique. *(trama com o primeiro byte da resposta HTTP)*

![[ethernet113667.png]]

**Resposta esperada** (confirma com a captura):
- **Origem:** `d4:7f:35:16:e2:9f` (Cisco_16:e2:9f), o *gateway*/router da rede local, que entrega a resposta do servidor.
- **Destino:** `1e:6c:c2:c2:3a:2c`, o computador do aluno (`172.26.193.235`).
- **Justificação:** é o caminho inverso do pedido. Os IP mantêm-se fim-a-fim (`193.136.9.240` → `172.26.193.235`), mas os MAC são os do **último salto**, não os do servidor.

#### Pergunta 5
> Atendendo ao conceito de desencapsulamento protocolar, identifique os vários protocolos contidos na trama recebida. Represente-os num esquema por camadas.

![[hypertext-transfer-protocol.png]]

**Resposta.** Na trama 11367 (confirma que o Wireshark mostra a mesma estrutura), os protocolos são, de baixo para cima:

```
+-----------------------------------------+
| Aplicação   : HTTP  (HTTP/1.1 301 ...)  |   ← payload do TCP
+-----------------------------------------+
| Transporte  : TCP   (porta 80 → 64796)  |   ← payload do IP
+-----------------------------------------+
| Rede        : IPv4  (193.136.9.240 →    |   ← payload da Ethernet
|                      172.26.193.235)    |
+-----------------------------------------+
| Ligação     : Ethernet II (Type 0x0800) |
+-----------------------------------------+
```

Durante o processo de desencapsulamento, cada camada analisa o seu cabeçalho e passa o payload (dados) à camada superior: a camada Ethernet (indicada pelo campo Type `0x0800`) passa os dados ao protocolo IPv4; o IPv4 (com campo Protocol = 6) passa os dados ao TCP; e o TCP (através da porta 80) entrega os dados finais ao HTTP.

Cada camada, no desencapsulamento, lê o seu cabeçalho e entrega o *payload* à camada seguinte: a Ethernet (campo *Type* `0x0800`) entrega ao IPv4, o IPv4 (campo *Protocol* = 6) entrega ao TCP, e o TCP (porta 80) entrega ao HTTP.

---

### 4. Protocolo ARP 

**O que tens de fazer no CORE:**
1. `sudo core` → montar a rede (Fig. 2): Depto A = 4 PCs + 1 servidor ligados a um **switch** → RA; Depto B = 3 PCs ligados a um **hub** → RB; RA–RB ponto-a-ponto; RB → RC.
2. Apagar as caches ARP (`arp -d` ou reiniciar a rede).
3. Escolher um *host* de um departamento, iniciar o Wireshark nele, fazer `ping` a **dois** hosts do outro departamento, parar a captura e filtrar por `arp`.
4. Guardar screenshots: tabela `arp`, trama ARP Request, trama ARP Reply.

**Respostas esperadas** (para saberes o que procurar; confirma com a tua captura):

#### Pergunta 6
> Abra uma consola no host onde efetuou o ping. Observe o conteúdo da tabela ARP com o comando `arp`.
- **a)** Colunas (`man arp`): *Address* (IP do vizinho), *HWtype* (tipo de ligação, normalmente `ether`), *HWaddress* (endereço MAC resolvido), *Flags Mask* (`C` = entrada completa/dinâmica; `M` = permanente) e *Iface* (interface de rede).
- **b)** Em princípio um dos **routers**, o que tem mais vizinhos diretos na mesma rede local. O RA tem na LAN do Depto A 4 PCs + 1 servidor (5 hosts) e ainda o RB, ou seja, até 6 entradas. O RB só tem o hub (3 PCs) + RA + RC (5). Justifica com o que vês na topologia que montaste.
- **c)** Para completar a tabela do router, faz `ping` do router a **todos** os hosts da LAN dele (ou o inverso), de forma a gerar um pedido ARP para cada vizinho. Mostra a tabela completa com `arp`.

![[topologia.png]]

ping n5 -> n13

![[ping1.png]]

![[arpn51.png]]

ping n5 -> n12

![[ping2.png]]

Dual ping tabela arp 
![[dualping.png]]


- **a)** Colunas (`man arp`): *Address* (IP do vizinho), *HWtype* (tipo de ligação, normalmente `ether`), *HWaddress* (endereço MAC resolvido), *Flags Mask* (`C` = entrada completa/dinâmica; `M` = permanente) e *Iface* (interface de rede).
- **b)** Em princípio um dos **routers**, o que tem mais vizinhos diretos na mesma rede local. O RA tem na LAN do Depto A 4 PCs + 1 servidor (5 hosts) e ainda o RB, ou seja, até 6 entradas. O RB só tem o hub (3 PCs) + RA + RC (5). Justifica com o que vês na topologia que montaste.
- **c)** Para completar a tabela do router, faz `ping` do router a **todos** os hosts da LAN dele (ou o inverso), de forma a gerar um pedido ARP para cada vizinho. Mostra a tabela completa com `arp`.

#### Pergunta 7
> Qual é o valor hexadecimal dos endereços origem e destino na trama Ethernet que contém o ARP Request? Como interpreta e justifica o endereço destino usado?

- Origem: MAC do host que fez o ping. Destino: `ff:ff:ff:ff:ff:ff` (*broadcast*).
- **Justificação:** o host conhece o IP do destino mas **não o MAC**, que é exatamente o que quer descobrir. Por isso envia a todos na rede local, e só o dono do IP respondem.

#### Pergunta 8
> Qual o valor hexadecimal no campo Tipo da trama Ethernet? O que indica?

- `0x0806`: indica que o *payload* da trama é uma mensagem **ARP**.

#### Pergunta 9
> Observando a mensagem ARP, como pode saber que se trata efetivamente de um pedido ARP? Identifique o tipo de endereços contidos na mensagem ARP.

- Pelo campo **Opcode = 1** (*request*).
- Endereços: **hardware** = Ethernet/MAC (48 bits, 6 bytes) e **protocolo** = IPv4 (32 bits, 4 bytes).

alternativa:

- A mensagem identifica-se como um pedido ARP através do campo Opcode, que tem o valor 1 (*request*).
- A mensagem ARP contém endereços de hardware, neste caso Ethernet/MAC (com 48 bits ou 6 bytes de comprimento), e endereços de protocolo, neste caso IPv4 (com 32 bits ou 4 bytes de comprimento).

#### Pergunta 10
> Explicite, em linguagem comum, que tipo de pedido ou pergunta é feita pelo host de origem à rede?

- O pedido pode ser traduzido como  *"Quem tem o endereço IP X? Digam-me o vosso MAC (o meu é Y / o meu IP é Z)."* O campo *Target MAC* vai a zeros (`00:00:00:00:00:00`) porque é desconhecido.

#### Pergunta 11
> Localize a mensagem ARP que é a resposta ao pedido ARP efetuado.

- **a)** **Opcode = 2** (*reply*): indica que é uma resposta ARP.
- **b)** A resposta está no campo **Sender MAC address** da mensagem de resposta (o MAC de quem tinha o IP perguntado).
- **c)** A resposta é **unicast**, porque o MAC do requerente já é conhecido (veio no pedido, no *Sender MAC*), não é necessário difundir.

#### Pergunta 14
> Verifique se o ping feito ao segundo PC originou pacotes ARP e justifique a situação observada.

- **Não** originou. O destino está noutra rede, por isso o ARP resolveu o MAC do **router (gateway)**, que fica guardado na cache ARP. O segundo ping usa a entrada já existente.

#### Pergunta 15 (ARP)
> Identifique na mensagem ARP os campos que permitem definir o tipo e o tamanho dos endereços das camadas de rede e de ligação lógica que se pretendem mapear. Justifique os valores apresentados nesses campos.

| Campo | Valor | Significado |
|---|---|---|
| Hardware type | 1 | Ethernet |
| Protocol type | `0x0800` | IPv4 |
| Hardware size | 6 | MAC = 6 bytes |
| Protocol size | 4 | IPv4 = 4 bytes |


### 5. Domínios de colisão

#### Pergunta 15 (colisão)
> Através da opção tcpdump, verifique e compare como flui o tráfego nas diversas interfaces dos vários dispositivos no departamento A (LAN comutada) e no departamento B (LAN partilhada) quando gera tráfego intra-departamento.

Depto A
![[tcpdump1.png]]

Depto B
![[tcpdump2.png]]

**Experiência:** no CORE, duplo clique no dispositivo → *tcpdump* (ou `tcpdump -i eth0` no terminal). Faz `ping` entre dois PCs do mesmo departamento e vê quais as máquinas que **também** veem as tramas.

**Conclusão esperada:**
- **Depto B (hub):** o hub repete o sinal por todas as portas, por isso **todos** os hosts veem todas as tramas. Está tudo no mesmo **domínio de colisão** (largura de banda partilhada).
- **Depto A (switch):** depois de aprender os MAC (tabela de comutação), só o host de destino recebe a trama, e os restantes não veem o tráfego unicast. Cada porta é um domínio de colisão separado.
- **Exceção:** o primeiro pacote (e o ARP, que é *broadcast*) é difundido por todas as portas, porque o switch ainda não sabe o MAC do destino.
- O switch **divide** os domínios de colisão; o hub **não**.

Conclusão:

- Departamento B (utilização de um hub): O hub opera repetindo o sinal elétrico recebido por todas as suas portas ativas. Consequentemente, todos os hosts ligados a esse hub recebem e veem todas as tramas. Isto significa que todos os dispositivos partilham a mesma largura de banda e encontram-se no mesmo domínio de colisão.
- Departamento A (utilização de um switch): Um switch inteligente constrói uma tabela de comutação associando endereços MAC às respetivas portas. Após este processo de aprendizagem, as tramas unicast são encaminhadas apenas para a porta do host de destino, impedindo que outros dispositivos vejam esse tráfego. No caso de um switch, cada porta individual constitui um domínio de colisão distinto.
- Exceção no switch: O primeiro pacote enviado para um destino desconhecido (ou pacotes de broadcast, como pedidos ARP) é difundido por todas as portas (exceto a de origem), visto que o switch necessita de descobrir a porta correspondente ao MAC de destino.
- Em suma, um switch divide e isola os domínios de colisão da rede, enquanto que um hub não o faz.

#### Pergunta 16
> Apresente a tabela de comutação completa do switch do departamento A.

Tabela `< endereço MAC | porta >`: uma entrada por equipamento ligado ao switch (4 PCs + servidor + interface do RA). Para obter os MAC: `ifconfig` em cada host (campo `ether`). Atribui portas à tua escolha (por ex. `P1`…`P6`) e desenha-as no esquema.

| MAC | Porta |
|---|---|
| (PC1) | P1 |
| (PC2) | P2 |
| (PC3) | P3 |
| (PC4) | P4 |
| (Servidor) | P5 |
| (RA, interface eth ligada ao switch) | P6 |

---

## Parte 2: Redes sem fios (IEEE 802.11) 🔧

Abre `trace-wlan-tp1.pcap` no Wireshark. **Substitui XX pelo teu número de grupo.**

### 3. Acesso rádio (trama 4XX)

Selecione a trama **4XX** e expande *Radiotap Header* / *802.11 radio information*.

| # | O que procurar | Dica |
|---|---|---|
| 1 | **Frequência** (*Channel frequency*) e canal | 2,4 GHz: canal = (f − 2407)/5 (ex.: 2437 MHz = canal 6). 5 GHz: canal = (f − 5000)/5 (ex.: 5180 = canal 36) |
| 2 | **Versão da norma** | *PHY type* / flags no radiotap (a, b, g, n, ac) |
| 3 | **Débito** (*Data rate*) | Compara com o máximo da norma/interface: normalmente é inferior, porque o débito se ajusta (*rate adaptation*) à qualidade do sinal e ao ruído |
| 4 | **Força do sinal** (*Antenna signal*, em dBm) | Compara com a tabela do anexo: −30 dBm máximo; −55 excelente; −67 fiável; −80 pouco fiável; −90 quase sem ligação |

### 4. Scanning passivo e ativo

- **Q5 (trama beacon nº 100+NG):** é uma trama de **gestão** (*Management*), tipo `00`, subtipo `1000` (Beacon). Estão no campo **Frame Control** do cabeçalho 802.11.
- **Q5 (endereços MAC):** vê *Receiver/Destination* (`ff:ff:ff:ff:ff:ff`, *broadcast*), *Transmitter/Source* (MAC do AP) e *BSSID* (normalmente igual ao do AP). Conclusão: é difundida pelo AP para todas as estações no alcance.
- **Q6 (intervalo):** vê o campo *Beacon Interval* na trama. O valor típico é 100 TU, em que 1 TU = 1024 µs, ou seja, ≈ 102,4 ms. Na prática **não é exato**: o AP tem de esperar que o meio esteja livre (CSMA/CA), por isso há pequenos atrasos. Calcula as diferenças de tempo entre beacons consecutivos do mesmo AP para o demonstrar.
- **Q7 (SSID):** filtro `wlan.fc.type_subtype == 8` (beacons), e lê a coluna/campo *SSID* (*Tagged parameters*). Podes aplicar o SSID como coluna. Indica o filtro que usaste.
- **Q8 (probe request/response):** filtros `wlan.fc.type_subtype == 4 || wlan.fc.type_subtype == 5`. O *Probe Request* é enviado pela STA (normalmente em *broadcast*), e o *Probe Response* vem do AP, em *unicast* para a STA. Propósito: *active scanning*, em que a STA descobre APs sem esperar por beacons.

### 5. Processo de associação

- **Q9:** procura (filtro `wlan.fc.type == 0` e ordena por tempo) esta sequência, entre a mesma STA e o mesmo AP:
  1. Authentication (STA → AP) · subtipo `1011`
  2. Authentication (AP → STA)
  3. Association Request (STA → AP) · subtipo `0000`
  4. Association Response (AP → STA) · subtipo `0001`

  (Cada trama de gestão *unicast* é seguida de um **ACK**.)
- **Q10:** diagrama de sequência STA ↔ AP com as tramas acima e os números das tramas do Wireshark. Podes fazê-lo em TikZ (`sequence`) ou numa figura simples.

### 6. Transferência de dados (trama de dados 6XX)

- **Q11:** vê os bits **To DS** e **From DS** no *Frame Control*. Se To DS = 1, From DS = 0 (STA → AP → sistema de distribuição), **não** é local à WLAN, porque o destino final está fora da rede sem fios. Se To DS = 0 e From DS = 1, a trama vem do sistema de distribuição para a STA.
- **Q12:** transcreve os três endereços (*addr1/2/3*). O papel de cada um depende da direção:
  - To DS: addr1 = BSSID/AP · addr2 = STA (origem) · addr3 = destino (router)
  - From DS: addr1 = STA (destino) · addr2 = BSSID/AP · addr3 = origem (router)
- **Q13 (porquê os ACK):** no Wi-Fi o meio é partilhado e **não é possível detetar colisões** durante a transmissão (o emissor não consegue "ouvir" enquanto transmite), além de o canal rádio ter uma taxa de erros bem maior. Por isso usa-se CSMA/**CA** com confirmação explícita de cada trama (ACK), e a trama é retransmitida se o ACK não chegar. Na Ethernet com fios, a taxa de erros é muito baixa e (CSMA/CD) as colisões detetam-se.
- **Q14 (RTS/CTS):** procura dois exemplos de transferência (um com e outro sem RTS/CTS) e faz um diagrama de sequência para cada um:
  - **Com RTS/CTS:** `RTS (STA → AP)` → `CTS (AP → STA)` → `Data` → `ACK`
  - **Sem RTS/CTS:** `Data` → `ACK`

  Indica a direccionalidade (To DS / From DS) e os sistemas (STA, AP). RTS/CTS reduz colisões causadas por **estações escondidas** (*hidden terminal*), porque o CTS informa todas as estações (até as que não ouvem a STA) para adiarem a transmissão.

---

# Conclusões

- Encapsulamento e desencapsulamento (Ethernet → IP → TCP → HTTP) e cálculo da sobrecarga.
- Diferença entre endereçamento MAC (local, por salto) e IP (fim-a-fim).
- Funcionamento do ARP (broadcast no pedido, unicast na resposta, cache) e a sua restrição à rede local.
- Hub (um domínio de colisão) vs. switch (auto-aprendizagem, tabela de comutação).
- 802.11: tramas de gestão/controlo/dados, scanning passivo vs. ativo, associação, ACK e RTS/CTS.
- Dificuldades encontradas (ex.: captura Wi-Fi mostra tramas "pseudo-Ethernet").

---

# Para passar a LaTeX

- O enunciado exige **PDF**, com o nome `SCR-TP1-GXX.pdf` (XX = nº do grupo), e o relatório deve ter **apenas**: título e identificação do grupo, secção "Questões e Respostas" (transcrição da questão + resposta) e "Conclusões".
- Cada pergunta: transcreve o enunciado numa citação (`quote`) e responde por baixo.
- Os screenshots entram com `\includegraphics`, e as tabelas de cálculo (Q3) e o esquema de camadas (Q5) ficam bem em `tabular` / TikZ.
