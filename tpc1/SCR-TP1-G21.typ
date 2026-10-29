#import "@preview/fine-lncs:0.6.5": author, institute, lncs, proof, theorem

#set text(lang: "pt")

#let inst_uminho = institute(
  "Universidade do Minho",
  addr: "",
)

#show: lncs.with(
  title: "TP 1",
  // Opt.: Set this, if the title is too long to avoid linebreaks in the header of odd pages
  // running-title: "Short version of contribution title",
  // running-author: "Override the default author shortening",
  authors: (
    author(
      "Pedro Rosa",
      insts: (inst_uminho),
      oicd: "",
    ),
    author(
      "David Lobo",
      insts: (inst_uminho),
      oicd: "",
    ),
    author("Esteban Yepez", insts: (inst_uminho), oicd: "a117634"),
  ),
  bibliography: bibliography("refs.bib"),
  // optional configuration of page (takes all page parameter)
  // page_config: (paper: "a4")
)

= TO DO


== O que falta fazer no CORE (≈ 30-40 min)


#figure(
  image("imgs/topololgia2.png"),
  caption: [Topologia 2],
)

> *Problema nas capturas atuais:* `arp -d -a` *não apagou nada*, só listou a tabela (um `delete` bem-sucedido não imprime nada, e a entrada `10.0.0.1` continuou lá). A entrada que importa é a do gateway `10.0.0.1`. Sem a apagar, o `ping` pode nem gerar ARP.

== A) ARP Request/Reply (P7-P11, P14, P15) em *n5*
1. No terminal de n5: `export DISPLAY=:0.0` e `wireshark &` → capturar em `eth0`.

2. No terminal de n5:
  ```bash
  arp -d 10.0.0.1      # ou: ip neigh flush all
  arp                  # tem de aparecer vazia
  ping -c 1 10.0.3.20  # 1.º ping → gera ARP
  ping -c 1 10.0.3.21  # 2.º ping → não deve gerar ARP
  arp                  # só a entrada do gateway
  ```

#figure(
  image("imgs/prob2.png"),
  caption: [prob 2],
)

3. Parar a captura, filtro `arp`, e guardar screenshots de: lista (deve haver 2 tramas), **Ethernet II** do Request (endereços + Type), *Address Resolution Protocol* do Request expandido, e o mesmo para o Reply.


#figure(
  image("imgs/prob31.png"),
  caption: [prob 31],
)
#figure(
  image("imgs/prob32.png"),
  caption: [prob 32],
)
#figure(
  image("imgs/prob33.png"),
  caption: [prob 33],
)
#figure(
  image("imgs/prob34.png"),
  caption: [prob 34],
)
#figure(
  image("imgs/prob35.png"),
  caption: [prob 35],
)


== B) Tabela ARP de n7 (P6c) e MAC do switch (P16)
No terminal de *n7*:
```bash
for i in 20 21 22 23 24; do ping -c 1 10.0.0.$i; done
ping -c 1 10.0.1.2
arp
```
Esperam-se *6 entradas* (n2, n1, n3, n4, n5 por `eth0` + n8 por `eth1`). O mesmo ecrã dá-te os MAC para a P16.

#figure(
  image("imgs/probBn7.png"),
  caption: [problema B],
)

== C) tcpdump (P15 colisão): tem de ser tráfego **intra**-departamento
- *Depto A:* em n3, n4 e n5 correr `tcpdump -n -e -i eth0 icmp or arp`. Em n1: `ip neigh flush all` e depois `ping -c 5 10.0.0.20` (n1 → n2).

#figure(
  image("imgs/probCa.png"),
  caption: [problema C -deptA],
)

- *Depto B:* em n12 e n13 correr o mesmo `tcpdump`, **antes** de começar o ping. Em n11: `ping -c 5 10.0.3.21` (n11 → n12).

- Se em B o n13 *não* vir o ICMP entre n11 e n12, o `n10` não está a comportar-se como hub (no canvas, n6 e n10 têm o mesmo ícone). Verifica o tipo do nó e, se for preciso, troca por um **Hub**. (THIS WAS FIXED)
- O filtro `icmp or arp` evita confundir com os *hellos* OSPF (`224.0.0.5`), que aparecem em qualquer LAN.

#figure(
  image("imgs/probCb.png"),
  caption: [problema C - deptb],
)

= Parte 1: Nível de Ligação Lógica - Ethernet e Protocolo ARP
== Captura e análise de tramas ethernet

#figure(image("imgs/figura1.png"), caption: [Trama Ethernet])

=== Pergunta 1
Anote os endereços Ethernet ou MAC de origem e de destino de trama capturado com o pedido HTTP. Identifique a que sistemas se referem. Justifique.

#figure(
  image("imgs/ethernet.png", width: 60%),
  caption: [Ethernet],
)

*Resposta.*

- *Origem:* `1e:6c:c2:c2:3a:2c`. É a interface _Wi-Fi_ (`en0`) do computador onde se fez a captura, o endereço IP `172.26.193.235`. O _Wireshark_ mostra que o bit LG vale 1, ou seja, não é o endereço de fábrica da placa. É um endereço aleatório gerado pelo sistema operativo (recurso de privacidade do macOS).

- *Destino:* `d4:7f:35:16:e2:9f`, identificado pelo _Wireshark_ como `Cisco_16:e2:9f` (bit LG 0, endereço de fábrica; bit IG 0, _unicast_). É o equipamento de primeiro salto da rede (router, ou o AP da _Eduroam_) e não o servidor _web_.

- *Justificação:* o IP destino (`193.136.9.240`, marco.uminho.pt) é de outra rede. Como o servidor não está na rede local, a trama é entregue ao _router_, que a encaminha. Os endereços MAC têm significado apenas na ligação local (mudam em cada salto), enquanto os IP são fim-a-fim.

=== Pergunta 2
Analisando os campos do cabeçalho da trama capturada, diga, justificando, qual o protocolo encapsulado nessa trama.

- Resposta: O protocolo encapsulado é o IPv4. O campo _Type_ do cabeçalho Ethernet vale `0x0800` (nos bytes 12-13 da trama, `08 00`, linha `0000` do `hex dump`), valor que identifica IPv4.

=== Pergunta 3
Quantos bytes são usados desde o início da trama até ao caractere ASCII "G" do método `HTTP GET`? Calcule e indique, em percentagem, a sobrecarga (_overhead_) introduzida pela pilha protocolar no envio do `HTTP GET` (considere os _bytes_ ocupados pela camada física e pelo FCS, indicados na Figura 1).


#figure(
  image("imgs/IP.png", width: 60%),
  caption: [IP],
)

#figure(
  image("imgs/TCP.png", width: 60%),
  caption: [TCP],
)

#figure(
  image("imgs/GET.png", width: 60%),
  caption: [GET],
)

#figure(caption: [whatever])[
  #table(
    columns: (auto, auto, 1fr),
    // align: left + buttom,
    table.hline(),
    table.header[Camada][_Bytes_][Evidência],
    table.hline(),
    [Ethernet II (cabeçalho)], [14], [$6 + 6 + 2$],
    [IPv4], [20], [_Header length_: 20 bytes],
    [TCP], [32], [_Header length_: 32 bytes ($20 + 12$ de opções: NOP, NOP, _Timestamps_)],
    [Total até o "G"], [66],
    table.hline(),
  )
]<table-1>

Tal e como esta ilustrado na @table-1 o "G" (`47`) está no offset `0x42` = 66 da trama (linha `0040` do _hex dump_: `cd 1d 47 45 54`), por isso são usados 66 _bytes_ antes do "G" (74 se contares o preâmbulo + SFD de 8 _bytes_).

*Sobrecarga:*
#list(
  [*Payload* HTTP (TCP payload) = 415 B. Confere: $66 + 415 = 481 B$ (tamanho da trama).],
  [Camada física: preâmbulo $7 B + "SFD" 1 B = 8 B$; $"FCS" = 4 B$.],
  [Tamanho total enviado: $8 + 481 + 4 = 493 B$],
  [nSobrecarga = $8 + 66 + 4 = 78 B$ ],
)
Sobrecarga = $78 / 493 approx 15,8 %$

=== Pergunta 4
Quais são os endereços Ethernet da origem e destino? A que sistemas de rede correspondem? Justifique. (trama com o primeiro _byte_ da resposta `HTTP`)

#figure(
  image("imgs/ethernet113667.png"),
  caption: [Ethernet 113667],
)

*Resposta (trama 11367)*
- *Origem:* `d4:7f:35:16:e2:9f` (`Cisco_16:e2:9f`, bit LG 0: endereço de fábrica). É o _router_ da rede local, que entrega ao computador a resposta do servidor.
- *Destino:* `1e:6c:c2:c2:3a:2c`, o computador do aluno (`172.26.193.235`), com bit LG 1 (enderço privado, o mesmo que era a origem do pedido)
- *Justificação:* são os endereços do pedido com os papéis trocados (_hex dump_: _bytes_ 0-5 = `1e 6c c2 c2 3a 2c`, _bytes_ 6-11 = `d4 7f 35 16 e2 9f`). Os IP mantêm-se fim-a-fim (`193.136.9.240` → `172.26.193.235`), mas os MAC são os do último salto: o servidor está noutra rede, logo o MAC de origem não é o dele. O TTL de $61$ (`0x3d`), inferior ao valor inicial típico de $64$, é coerente com a travessia de routers.

=== Pergunta 5
Atendendo ao conceito de desencapsulamento protocolar, identifique os vários protocolos contidos na trama recebida. Represente-os num esquema por camadas.

#figure(
  image("imgs/hypertext-transfer-protocol.png"),
  caption: [hypertext transfer protocol],
)

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
Durante o desencapsulamento, cada camada analisa o seu cabeçalho e passa o _payload_ à camada superior: a Ethernet (campo _Type_ `0x0800`) entrega os dados ao IPv4; o IPv4 (campo _Protocol_ = 6) entrega-os ao TCP; e o TCP (porta de origem 80) entrega-os ao HTTP. A resposta é um redirecionamento (`301`) para `https://marco.uminho.pt/ferramentas/CORE/xubuncore.html`, e o corpo é HTML (`Content-Length: 263`). O `Ack: 416` confirma os 415 bytes do GET (415 + 1).

== Protocolo ARP
=== Pergunta 6
Abra uma consola no host onde efetuou o ping. Observe o conteúdo da tabela ARP com o comando `arp`.

#figure(
  image("imgs/prob2.png"),
  caption: [Tabela ARP],
)

- *a)* Colunas (`man arp`): _Address_ (IP do vizinho), _HWtype_ (tipo de ligação, normalmente `ether`), _HWaddress_ (endereço MAC resolvido), _Flags_ Mask (`C` = entrada completa/dinâmica; `M` = permanente) e _Iface_ (interface de rede).
- *b)* Em princípio um dos _routers_, o que tem mais vizinhos diretos na mesma rede local. O RA tem na LAN do Depto A 4 PCs + 1 servidor (5 hosts) e ainda o RB, ou seja, até 6 entradas. O RB só tem o hub (3 PCs) + RA + RC (5). Justifica com o que vês na topologia que montaste.
- *c)* Para completar a tabela do router, fez-se `ping` a todos os hosts da sua LAN e a `n8`, de modo a gerar um pedido ARP para cada vizinho:

```bash
for i in 21 22 23 24; do ping -c 1 10.0.0.$1; done
ping -c 1 10.0.1.2
arp
```

#figure(
  image("imgs/probBn7.png"),
  caption: [Tabela ARP],
)

#figure(caption: [Tabela ARP])[
  #table(
    columns: (auto, auto, auto),
    // align: left + buttom,
    table.hline(),
    table.header[_Address_][_HWaddress_][_Iface_],
    table.hline(),
    [`10.0.0.20`], [`00:00:00:aa:00:00`], [`eth0`],
    [`10.0.0.21`], [`00:00:00:aa:00:01`], [`eth0`],
    [`10.0.0.22`], [`00:00:00:aa:00:02`], [`eth0`],
    [`10.0.0.23`], [`00:00:00:aa:00:03`], [`eth0`],
    [`10.0.0.24`], [`00:00:00:aa:00:04`], [`eth0`],
    [`10.0.1.2`], [`00:00:00:aa:00:07`], [`eth1`],
    table.hline(),
  )
]<tabela-2>

=== Pergunta 7
Qual é o valor hexadecimal dos endereços origem e destino na trama Ethernet que contém o ARP Request? Como interpreta e justifica o endereço destino usado?

#figure(
  image("imgs/prob32.png"),
  caption: [Who has `10.0.0..01?`],
)
*Resposta (trama 305).* Origem: `00:00:00:aa:00:01` (n5). Destino: `ff:ff:ff:ff:ff:ff` (_broadcast_).

O n5 conhece o IP que quer alcançar (o _gateway_ `10.0.0.1`), mas não o MAC correspondente, que é precisamente o que pretende descobrir. Por isso o pedido é enviado em _broadcast_, para que todos os nós da rede local o recebam e só o dono do IP responda.

=== Pergunta 8
Qual o valor hexadecimal no campo Tipo da trama Ethernet? O que indica?

*Resposta.* `0x0806`. Indica que o _payload_ da trama é uma mensagem ARP.

=== Pergunta 9
Observando a mensagem ARP, como pode saber que se trata efetivamente de um pedido ARP? Identifique o tipo de endereços contidos na mensagem ARP.

*Resposta.* O campo _Opcode_ tem o valor 1 (request). A mensagem contém endereços de hardware, neste caso Ethernet/MAC (_Hardware_ type 1, 6 bytes ou 48 bits), e endereços de protocolo, neste caso IPv4 (_Protocol type_ `0x0800`, 4 _bytes_ ou 32 _bits_).

=== Pergunta 10
Explicite, em linguagem comum, que tipo de pedido ou pergunta é feita pelo host de origem à rede?

*Resposta.* «Quem tem o endereço IP 10.0.0.1? Respondam a 10.0.0.21 (MAC `00:00:00:aa:00:01`).» O campo `Target MAC` vai a zeros (`00:00:00:00:00:00`) porque é o que se pretende descobrir.

=== Pergunta 11
Localize a mensagem ARP que é a resposta ao pedido ARP efetuado.

#figure(
  image("imgs/prob33.png"),
  caption: [],
)
*Resposta*
- *a)* Opcode = 2 (_reply_): indica que é uma resposta ARP.
- *b)* A resposta está no campo _Sender MAC address_ da mensagem de resposta (o MAC de quem tinha o IP perguntado).
- *c)* A resposta é _unicast_, porque o MAC do requerente já é conhecido (veio no pedido, no _Sender MAC_), não é necessário difundir.

=== Pergunta 14
Verifique se o ping feito ao segundo PC originou pacotes ARP e justifique a situação observada.

*Resposta.* Não. O n5 só enviou um pedido ARP (trama 305, para o _gateway_). Os dois destinos (`10.0.3.20` e `10.0.3.21`) estão fora da LAN, pelo que o ARP serve apenas para obter o MAC do _gateway_ (`10.0.0.1`), que fica guardado na cache (`arp` mostra a entrada com a _flag_ `C`). O segundo `ping` reutiliza essa entrada, sem novo pedido ARP.

=== Pergunta 15
Identifique na mensagem ARP os campos que permitem definir o tipo e o tamanho dos endereços das camadas de rede e de ligação lógica que se pretendem mapear. Justifique os valores apresentados nesses campos.

*Resposta* (Frames 305 a 306)

#figure(
  table(
    columns: 3,
    table.hline(),
    table.header[Campo][Valor][Signinficado],
    table.hline(),
    [`Hardware type`], [1], [Ethernet (camada de ligação)],
    [`Protocol`], [`0x0800`], [IPv4 (camada de redes)],
    [`Hardware size`], [6], [$"Endereço MAC" = 6 "bytes"$],
    [`Protocol size`], [4], [$"Endereço IPv4" = 4 "bytes"$],
    table.hline(),
  ),
)

== Domínios de colisão
=== Pergunta 15
Através da opção tcpdump, verifique e compare como flui o tráfego nas diversas interfaces dos vários dispositivos no departamento A (LAN comutada) e no departamento B (LAN partilhada) quando gera tráfego intra-departamento.

=== Pergunta 16
Apresente a tabela de comutação completa do switch do departamentos

= Redes sem fio (IEEE 802.11)
== Accesso Rádio

