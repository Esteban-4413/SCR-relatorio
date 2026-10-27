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
  thanks: "Supported by organization x.",
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
  abstract: [
    The abstract should briefly summarize the contents of the paper in
    15--250 words.
  ],
  bibliography: bibliography("refs.bib"),
  // optional configuration of page (takes all page parameter)
  // page_config: (paper: "a4")
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


Sobrecarga:
#list(
  [*Payload* HTTP (TCP payload) = *415 B*. Confere: 66 + 415 = 481 B (tamanho da trama).],
  [Camada física: preâmbulo 7 B + SFD 1 B = *8 B*; FCS = *4 B*.],
  [Tamanho total enviado: 8 + 481 + 4 = *493 B*],
  [Sobrecarga = 8 + 66 + 4 = *78 B* ],
)
*Sobrecarga = $78 / 493 approx 15,8 %$*

=== Pergunta 4
Quais são os endereços Ethernet da origem e destino? A que sistemas de rede correspondem? Justifique. *(trama com o primeiro byte da resposta HTTP)*

=== Pergunta 5
Atendendo ao conceito de desencapsulamento protocolar, identifique os vários protocolos contidos na trama recebida. Represente-os num esquema por camadas.

== Protocolo ARP
=== Pergunta 6
Abra uma consola no host onde efetuou o ping. Observe o conteúdo da tabela ARP com o comando `arp`.

- **a)** Colunas (`man arp`): *Address* (IP do vizinho), *HWtype* (tipo de ligação, normalmente `ether`), *HWaddress* (endereço MAC resolvido), *Flags Mask* (`C` = entrada completa/dinâmica; `M` = permanente) e *Iface* (interface de rede).
- **b)** Em princípio um dos **routers**, o que tem mais vizinhos diretos na mesma rede local. O RA tem na LAN do Depto A 4 PCs + 1 servidor (5 hosts) e ainda o RB, ou seja, até 6 entradas. O RB só tem o hub (3 PCs) + RA + RC (5). Justifica com o que vês na topologia que montaste.
- **c)** Para completar a tabela do router, faz `ping` do router a **todos** os hosts da LAN dele (ou o inverso), de forma a gerar um pedido ARP para cada vizinho. Mostra a tabela completa com `arp`.

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
- **a)** **Opcode = 2** (*reply*): indica que é uma resposta ARP.
- **b)** A resposta está no campo **Sender MAC address** da mensagem de resposta (o MAC de quem tinha o IP perguntado).
- **c)** A resposta é **unicast**, porque o MAC do requerente já é conhecido (veio no pedido, no *Sender MAC*), não é necessário difundir.

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

