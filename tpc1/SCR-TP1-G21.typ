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


![[topololgia2.png]]

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
Anote os endereços Ethernet ou (MAC) de origem e de destino de trama capturado com o pedido HTTP. Identifique a que sistemas se referem. Justifique.

#figure(
  image("imgs/ethernet.png", width: 60%),
  caption: [Ethernet],
)

*Resposta.*

- *Origem:* `1e:6c:c2:c2:3a:2c`. É a interface Wi-Fi (`en0`) do computador onde se fez a captura, o endereço IP `172.26.193.235`. O Wireshark mostra que o bit LG vale 1, ou seja, não é o endereço de fábrica da placa. É um endereço *privado/aleatório* gerado pelo sistema operativo (recurso de privacidade do macOS).

- *Destino:* `d4:7f:35:16:e2:9f`, identificado pelo Wireshark como `Cisco_16:e2:9f` (bit LG 0, endereço de fábrica; bit IG 0, *unicast*). É o equipamento de *primeiro salto* da rede (router, ou o AP da Eduroam) e *não* o servidor web.

- *Justificação:* o IP destino (`193.136.9.240`, marco.uminho.pt) é de outra rede. Como o servidor não está na rede local, a trama é entregue ao router, que a encaminha. Os endereços MAC têm significado apenas na ligação local (mudam em cada salto), enquanto os IP são fim-a-fim.

=== Pergunta 2
Analisando os campos do cabeçalho da trama capturada, diga, justificando, qual o protocolo encapsulado nessa trama.

- Resposta: O protocolo encapsulado é o *IPv4*. O campo _Type_ do cabeçalho Ethernet vale `0x0800` (nos bytes 12-13 da trama, `08 00`, linha `0000` do `hex dump`), valor que identifica *IPv4*.

=== Pergunta 3
Quantos bytes são usados desde o início da trama até ao caractere ASCII "G" do método HTTP GET? Calcule e indique, em percentagem, a sobrecarga (*overhead*) introduzida pela pilha protocolar no envio do HTTP GET (considere os bytes ocupados pela camada física e pelo FCS, indicados na Figura 1).


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
    table.header[Camada][Bytes][Evidência],
    table.hline(),
    [Ethernet II (cabeçalho)], [14], [$6 + 6 + 2$],
    [IPv4], [20], [_Header length_: 20 bytes],
    [TCP], [32], [_Header length_: 32 bytes ($20 + 12$ de opções: NOP, NOP, Timestamps)],
    [Total até o "G"], [66],
    table.hline(),
  )
]<table-1>

Tal e como esta ilustrado em @table-1 o "G" (`47`) está no offset `0x42` = 66 da trama (linha `0040` do *hex dump*: `cd 1d 47 45 54`), por isso são usados *66 bytes* antes do "G" (74 se contares o preâmbulo + SFD de 8 bytes).

*Sobrecarga:*
#list(
  [*Payload* HTTP (TCP payload) = *415 B*. Confere: 66 + 415 = 481 B (tamanho da trama).],
  [Camada física: preâmbulo 7 B + SFD 1 B = *8 B*; FCS = *4 B*.],
  [Tamanho total enviado: 8 + 481 + 4 = *493 B*],
  [nSobrecarga = 8 + 66 + 4 = *78 B* ],
)
Sobrecarga = $78 / 493 approx 15,8 %$

=== Pergunta 4
Quais são os endereços Ethernet da origem e destino? A que sistemas de rede correspondem? Justifique. *(trama com o primeiro byte da resposta HTTP)*

=== Pergunta 5
Atendendo ao conceito de desencapsulamento protocolar, identifique os vários protocolos contidos na trama recebida. Represente-os num esquema por camadas.

== Protocolo ARP
=== Pergunta 6
Abra uma consola no host onde efetuou o ping. Observe o conteúdo da tabela ARP com o comando `arp`.

- *a)* Colunas (`man arp`): *Address* (IP do vizinho), *HWtype* (tipo de ligação, normalmente `ether`), *HWaddress* (endereço MAC resolvido), *Flags Mask* (`C` = entrada completa/dinâmica; `M` = permanente) e *Iface* (interface de rede).
- *b)* Em princípio um dos *routers*, o que tem mais vizinhos diretos na mesma rede local. O RA tem na LAN do Depto A 4 PCs + 1 servidor (5 hosts) e ainda o RB, ou seja, até 6 entradas. O RB só tem o hub (3 PCs) + RA + RC (5). Justifica com o que vês na topologia que montaste.
- *c)* Para completar a tabela do router, faz `ping` do router a *todos* os hosts da LAN dele (ou o inverso), de forma a gerar um pedido ARP para cada vizinho. Mostra a tabela completa com `arp`.

=== Pergunta 7
Qual é o valor hexadecimal dos endereços origem e destino na trama Ethernet que contém o ARP Request? Como interpreta e justifica o endereço destino usado?

=== Pergunta 8
Qual o valor hexadecimal no campo Tipo da trama Ethernet? O que indica?

=== Pergunta 9
Observando a mensagem ARP, como pode saber que se trata efetivamente de um pedido ARP? Identifique o tipo de endereços contidos na mensagem ARP.

=== Pergunta 10
Explicite, em linguagem comum, que tipo de pedido ou pergunta é feita pelo host de origem à rede?

=== Pergunta 11
Localize a mensagem ARP que é a resposta ao pedido ARP efetuado.
- *a)* *Opcode = 2* (*reply*): indica que é uma resposta ARP.
- *b)* A resposta está no campo *Sender MAC address* da mensagem de resposta (o MAC de quem tinha o IP perguntado).
- *c)* A resposta é *unicast*, porque o MAC do requerente já é conhecido (veio no pedido, no *Sender MAC*), não é necessário difundir.

=== Pergunta 14
Verifique se o ping feito ao segundo PC originou pacotes ARP e justifique a situação observada.

=== Pergunta 15
Identifique na mensagem ARP os campos que permitem definir o tipo e o tamanho dos endereços das camadas de rede e de ligação lógica que se pretendem mapear. Justifique os valores apresentados nesses campos.

== Domínios de colisão
=== Pergunta 15
Através da opção tcpdump, verifique e compare como flui o tráfego nas diversas interfaces dos vários dispositivos no departamento A (LAN comutada) e no departamento B (LAN partilhada) quando gera tráfego intra-departamento.

=== Pergunta 16
Apresente a tabela de comutação completa do switch do departamentos

= Redes sem fio (IEEE 802.11)
== Accesso Rádio

