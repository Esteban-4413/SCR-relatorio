=== Pergunta 1

    Frequência e Canal: Analisando a secção "802.11 radio information" no Wireshark, identificámos que a rede sem fios está a operar na frequência de 2412 MHz. Verificámos também que esta frequência corresponde ao Canal 1.

=== Pergunta 2

    Versão da Norma: Através do campo "PHY type", constatámos que a versão da norma IEEE 802.11 que está a ser usada na trama capturada é a 802.11b (HR/DSSS).

=== Pergunta 3

    Débito da Trama: Observámos que a trama escolhida foi enviada a um débito (Data rate) de 1.0 Mb/s.

    Justificação do Débito Máximo: Concluímos que este valor não corresponde ao débito máximo a que a interface Wi-Fi pode operar. A norma 802.11b suporta velocidades teóricas até 11 Mb/s. O envio a 1.0 Mb/s justifica-se pelo facto
   de se tratar de uma trama de gestão (um Beacon); estas tramas são transmitidas intencionalmente na taxa base mais baixa para maximizar o alcance da propagação do sinal e garantir que todos os dispositivos
   na vizinhança consigam ouvi-las e descodificá-las com sucesso, independentemente da distância.

=== Pergunta 4

    Força do Sinal e Qualidade: Verificámos na captura que a força do sinal (Signal strength) recebido é de -46 dBm. Além disso, a análise indica um nível de ruído (Noise level) de -93 dBm, o que resulta
   numa relação Sinal/Ruído (Signal/noise ratio) de 47 dB. Tendo em conta o que nos é pedido para verificar face à tabela em Anexo[cite: 16], e perante valores tão favoráveis (um sinal forte de -46 dBm e 
   um excelente SNR de 47 dB), concluímos que a qualidade expectável de receção da trama é classificada como excelente, garantindo uma transmissão muito fiável e sem falhas.

=== Pergunta 5

    Type: Management frame (0)
    Subtype: 8

    Conclusão: A combinação destes dois campos resulta na classificação agregada que observámos na linha destacada a azul, identificando o pacote completo como "Type/Subtype: Beacon frame (0x0008)".   

=== Pergunta 6

    Origem (Source / BSSID): 74:9b:e8:f3:9a:46. Identificado pelo Wireshark como HitronTechno_f3:9a:46, que verificámos corresponder ao endereço MAC do Ponto de Acesso (AP) responsável pela emissão da trama beacon.

    Destino (Destination): ff:ff:ff:ff:ff:ff. Trata-se do endereço físico de Broadcast.

    Conclusão: Concluímos que a trama é gerada por um Ponto de Acesso (AP) e enviada para o endereço de Broadcast, de forma a ser recebida por todas as estações (STA) na sua área de cobertura, servindo o 
  propósito de anunciar a presença da rede e os seus parâmetros.

=== Pergunta 7

    Intervalo previsto: O valor que analisámos (Beacon Interval) no cabeçalho de gestão é de 0.102400 segundos (102,4 milissegundos).

    Justificação: As redes sem fios 802.11 utilizam o mecanismo de contenção e acesso ao meio CSMA/CA. Sabemos que, antes de emitir o beacon, o AP tem de escutar o meio. Se o canal sem fios estiver ocupado por outra 
  transmissão no momento agendado, o AP é forçado a aguardar até que o meio fique livre, o que verificámos introduzir pequenos atrasos na periodicidade destas tramas.

=== Pergunta 8

    Resposta: Através da captura que nos foi fornecida, identificámos o SSID FlyingNet.

    Modo de obtenção (Filtro): Para isolarmos estas tramas, utilizámos o filtro de visualização wlan.fc.type_subtype == 8 no Wireshark, o que nos permitiu selecionar apenas as tramas de gestão do subtipo Beacon.

    Modo de obtenção (Análise): Extraímos o nome específico da rede selecionando um destes pacotes e expandindo a secção IEEE 802.11 Wireless Management > Tagged parameters, localizando depois o campo Tag: SSID parameter set.

=== Pergunta 9

    Tramas Identificadas: Na captura fornecida, conseguimos observar um exemplo claro de probing ativo através da trama 2178 (Probe Request), enviada pela estação de origem AltoBeam_08:32:99, que é 
  imediatamente seguida pelas tramas 2179 e 2180 (Probe Response), enviadas pelo AP TpLink_31:e2:39 como resposta direta. Outro par evidente que encontrámos é o Probe Request da trama 2068 (estação HP_d0:a0:11) e as respetivas
  respostas nas tramas 2070 e 2071.
   
    Probe Request (Endereçamento): Como observámos na coluna "Destination" da captura (ex: pacotes 2068 e 2178), esta trama é endereçada para o MAC de Broadcast (ff:ff:ff:ff:ff:ff).
   
    Probe Request (Propósito): O objetivo é o dispositivo cliente efetuar um scanning ativo, enviando um pedido a todos os dispositivos para descobrir as redes sem fios disponíveis na vizinhança ou procurar um SSID específico.
   
    Probe Response (Endereçamento): Verificámos que a trama (ex: pacotes 2070, 2179 ou o detalhe do pacote 2035) é endereçada em Unicast diretamente para o endereço MAC específico da estação que iniciou o 
  pedido (ex: HP_d0:a0:11, AltoBeam_08:32:99 ou fe:bd:a5:05:6c:84).
  
    Probe Response (Propósito): O objetivo é o Ponto de Acesso (AP) responder de forma direcionada ao dispositivo requerente, confirmando a sua presença na rede e fornecendo-lhe os parâmetros de 
  comunicação (como SSID, canais e taxas suportadas).


=== Pergunta 10

    Sequência de Tramas Identificada: Com base na print que tirámos, conseguimos observar várias sequências completas de associação. Um exemplo claro corresponde ao conjunto das tramas 2042, 2044, 2046 e 2048, trocadas entre a estação `fe:bd:a5:05:6c:84` e o AP `HitronTechno_f3:9a:...` para a rede SSID "FlyingNet".

    Detalhamento da Sequência:

    1. Trama 2042: Authentication (da STA `fe:bd...` para o AP `HitronTechno...`).
    2. Trama 2044: Authentication (do AP `HitronTechno...` para a STA `fe:bd...`).
    3. Trama 2046: Association Request (da STA `fe:bd...` para o AP `HitronTechno...`).
    4. Trama 2048: Association Response (do AP `HitronTechno...` para a STA `fe:bd...`).

    Outros exemplos visíveis: Notámos que a mesma sequência completa também é verificável para a estação `Apple_71:41:a1` (tramas 10365, 10368, 10372, 10376) e para a 
  estação `AzureWaveTec_0f:0e:...` (tramas 10530, 10532, 10536, 10538).



=== Pergunta 11

    Diagrama de Sequência (Exemplo com a STA fe:bd:a5:05:6c:84):


    STA (fe:bd:a5:05:6c:84)                      AP (HitronTechno)
          |                                             |
          | ---- 1. Authentication (Trama 2042) ------> |
          | <--- 2. Authentication (Trama 2044) ------- |
          |                                             |
          | ---- 3. Association Request (Trama 2046) -> |
          | <--- 4. Association Response (Trama 2048) - |
          |                                             |
          V                                             V

    Justificação do fluxo: Como demonstrámos nas múltiplas sequências que analisámos no Wireshark, o processo de associação nas redes IEEE 802.11 exige que a estação complete a fase de autenticação com sucesso antes de 
  emitir a trama *Association Request*. O processo termina com o AP a enviar a *Association Response*, finalizando a ligação.

=== Pergunta 12

    Direcionalidade e Destino: Analisando a trama 621 e observando o cabeçalho do frame control field, ao abrir as flags, no DS status, temos (To DS: 1 From Ds: 0) que, quanto à direcionalidade, nos indica que a trama está a ser enviada de um dispositivo para o Access Point(AC).

    Análise de Endereços: Um pouco abaixo, fora das flags, temos os endereços Destination address (O endereço Mac do dispositivo destinatário) e o Receiver address (o endereço mac do Access Point) ambos iguais (74:9b:e8:f3:9a:46).

    Conclusão: Como o destino da trama é o access point, conclui-se que a trama é local à WLan.

=== Pergunta 13

    Endereço da Estação (STA): O endereço MAC do host sem fios (STA) está disponível no STA address (b8:2d:28:7a:9b:68).

    Endereço do Ponto de Acesso (AP): O endereço MAC do Access Point é o endereço associado ao BSS Id (74:9b:e8:f3:9a:46).

    Endereço do Router: E finalmente, o endereço MAC do router de acesso ao sistema de distribuição também será o mesmo (74:9b:e8:f3:9a:46).

  === Pergunta 14 

  Redes Ethernet (com fios): Verificámos que nestas redes se utiliza o mecanismo de acesso CSMA/CD (Collision Detection). Como a comunicação é feita por um cabo elétrico, a placa de rede consegue transmitir dados e, ao mesmo tempo, "escutar" a tensão no cabo. Se duas máquinas transmitirem ao mesmo tempo, ocorre uma alteração física no sinal elétrico que ambas detetam imediatamente (detetam a colisão), abortando o envio. Concluímos que, como a rede deteta as falhas em tempo real, não precisa de confirmações constantes para cada pacote.

    Redes Wi-Fi (sem fios): Constatámos que se utiliza o mecanismo CSMA/CA (Collision Avoidance). Um rádio Wi-Fi funciona em modo half-duplex, o que significa que não consegue transmitir e receber dados em simultâneo no mesmo canal. Quando um dispositivo está a emitir uma trama para o ar, fica "surdo" ao que se passa à sua volta e não consegue detetar se o seu sinal colidiu com o de outro dispositivo.

    A função do ACK: Analisando o funcionamento, percebemos que, como o emissor Wi-Fi não tem forma de detetar colisões por si próprio, necessita de um 
    mecanismo de confirmação explícita. É por isso que o recetor é obrigado a enviar uma trama de controlo ACK (Acknowledge) sempre que recebe uma trama de
    dados com sucesso. Se o emissor original não receber esse ACK num curto espaço de tempo, assume que houve uma colisão (ou muita interferência) e volta a retransmitir a trama original.


=== Pergunta 15

  
    Sistemas Envolvidos: Ao analisarmos a captura, identificámos que a comunicação ocorre essencialmente entre a estação cliente (STA) `AMPAKTechnol_7a:9b:...` e o ponto de acesso (AP) `HitronTechno_f3:9a:...`.

    1. Diagrama de Sequência: Transferência COM opção RTS/CTS
    Com base nos pacotes 288 a 291 da nossa captura, traçámos o seguinte processo. Este diagrama ilustra de forma clara a "pré-reserva" do canal, que 
    acontece em 4 passos:

    STA (AMPAKTechnol)                                      AP (HitronTechno)
            |                                                       |
            | --- 1. Request-to-send (Pacote 288) ----------------> | (Pedido)
            | <--- 2. Clear-to-send (Pacote 289) ------------------ | (Autorização)
            |                                                       |
            | --- 3. QoS Data (Pacote 290) -----------------------> | (Envio de Dados)
            | <--- 4. Block Ack (Pacote 291) ---------------------- | (Confirmação)
            |                                                       |
            V                                                       V

    2. Diagrama de Sequência: Transferência SEM opção RTS/CTS
    Olhando agora para os pacotes 368 e 369, ilustrámos uma transferência direta mais comum, que ocupa apenas 2 passos. Neste caso não existe uma pré-reserva; a 
    estação simplesmente verifica se o canal está livre e avança com a transmissão:

    STA (AMPAKTechnol)                                      AP (HitronTechno)
            |                                                       |
            | --- 1. Null function [No data] (Pacote 368) --------> | (Envio de Dados)
            | <--- 2. Acknowledgement (Pacote 369) ---------------- | (Confirmação)
            |                                                       |
            V                                                       V
    
    Nota de análise: Pode parecer um pouco estranho usar um pacote chamado "Null function (No data)" para este exemplo, mas constatámos que o protocolo 802.11 classifica tecnicamente este pacote como uma trama de Dados (Type 2). Por esse motivo, considerámo-lo um exemplo perfeitamente válido para ilustrar uma transferência de 
    dados sem RTS/CTS que exige uma confirmação imediata.

    === Conclusão Parte 2

    Através da análise de tráfego no Wireshark, o nosso grupo consolidou de forma prática os conceitos teóricos do protocolo IEEE 802.11. Aprendemos a identificar parâmetros cruciais da camada física, como a frequência, a norma em uso e a avaliar a qualidade da ligação através da relação Sinal/Ruído (SNR). Observámos também as diferenças entre o scanning passivo (através de tramas Beacon enviadas a baixo débito para garantir maior alcance) e ativo (Probe Request/Response), mapeando na prática o processo estruturado que exige sempre a autenticação prévia de um dispositivo antes de concluir a sua associação à rede.

A nível estrutural e de acesso ao meio, compreendemos a arquitetura complexa de endereçamento do Wi-Fi face à Ethernet e a utilização de flags de direcionalidade para rastrear a informação. Consolidámos a distinção fundamental entre CSMA/CD e CSMA/CA, percebendo que a natureza half-duplex dos rádios impede a deteção nativa de colisões. Esta limitação revelou-nos a importância vital das tramas de confirmação (ACK) e dos mecanismos de pré-reserva de canal (RTS/CTS), ilustrando perfeitamente como o protocolo contorna as adversidades e garante fiabilidade num meio de transmissão partilhado e suscetível a interferências.
