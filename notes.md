# Notas de pesquisa

## O que é Zero Trust Architecture

### Fonte 1: YouTube Video
[What Is Zero Trust Architecture (ZTA) ? NIST 800-207 Explained](https://www.youtube.com/watch?v=5Kq64vOgE10)

#### The basics
Zero trust principles:
- Never trust, always verify.
- After trust; constantly re-assess.
- No concept of internal or external users.

```mermaid 
flowchart LR
    S["<b>Subject</b>"] --> UZ(["Untrusted Zone"])
    UZ --> PDP["<b>Policy Decision and Enforcement Point<br>(PDP/PEP)</b>"]
    PDP --> ITZ(["Implicit Trust Zone"])
    ITZ --> R["<b>Resource</b><br>• System<br>• Application<br>• Dataset<br>• Service"]
```

Tenants
1. All data sources and computing services are considered resources.
2. All communication is secured regardless of network location.
3. Access to individual enterprise resources is granted on a per session basis.
4. Every access request is evaluated by a dynamic policy. This dynamic policy should consider identity and authentication as well as device security posture and other contextual factors.
5. Authentication and authorization is strictly enforced before the subject is given access to a resource.
6. Enterprise monitors and measures the integrity and security posture of all owned and associated assets.
7. Loggin and continuous reassessment of the current state of assets, network infrastructure, and communication

### Fonte 2: Revisão sistemática
- Contexto: ZTA surge como resposta às limitações do Primeter-Based Security Model (PBSM) face ao aumento do teletrabalho e da adoção da cloud.
- Dominios de Aplicação: A arquitetura ZTA é amplamente aplicada em setores criticos, incluin cuidados de saúde, redes 5G/6G, Internet das Coisas (IoT) e ambientes de metaverso.
- Desafios: A implementação enfrenta barreiras significativas como o aumento da latência de rede, dificuldades de integração com sistemas legados e a complexidade na gestão de políticas.

### Fonte 3: Survey sobre desafios e tendências
- Pilares Técnicos: A arquitetura foca-se em três pilares centrais: autenticação de identidade (para utilizadores e dispositivos), controlo de acesso (como RBAC, ABAC e ABE) e avaliação de confiança.

- Avaliação Contínua: Os algoritmos de avaliação de confiança utilizam métodos matemáticos avançados, tais como machine learning e lógica difusa, para recalcular o risco dinamicamente.

# Notas sobre o relatório

## Estrutura

### Introdução 
- Contexto e Motivação: A arquitetura ZTA surge como uma resposta necessária às limitações do Modelo de Segurança Baseado no Perímetro (PBSM).

- Catalisadores: Esta evolução foi impulsionada de forma significativa pelo aumento do teletrabalho e pela adoção generalizada da cloud.

- Princípio Fundamental: A premissa básica do ZTA baseia-se na regra de "nunca confiar, verificar sempre". Na sua conceção, deixa de existir qualquer distinção ou conceito de utilizadores "internos" versus "externos".

### Fundamentos e Princípios Base (NIST 800-207)
- Conceito de Recurso e Comunicação: Todas as fontes de dados e serviços de computação são categorizados como recursos, devendo toda a comunicação ser protegida independentemente da sua localização na rede.

- Fluxo de Decisão (Arquitetura Lógica): Um Sujeito (numa zona não confiável) tenta aceder ao Recurso através de um Ponto de Decisão e Aplicação de Políticas (PDP/PEP). Apenas após esta validação o sujeito entra na "Zona de Confiança Implícita".

- Gestão de Acessos e Políticas Dinâmicas:
  - O acesso aos recursos empresariais é concedido estritamente numa base "por sessão".

  - Os pedidos de acesso são avaliados mediante políticas dinâmicas que têm em conta a identidade, a autenticação, a postura de segurança do dispositivo e outros fatores de contexto.

  - A autenticação e autorização são aplicadas de forma estrita antes de qualquer acesso ao recurso ser concedido.

### Pilares técnicos e avaliação contínua de confiança
- Os Três Pilares: Tecnicamente, a ZTA assenta em três pilares centrais: autenticação de identidade (abrangendo utilizadores e dispositivos), controlo de acesso (utilizando modelos como RBAC, ABAC e ABE) e avaliação de confiança.

- Reavaliação Constante: A confiança nunca é definitiva; após o estabelecimento inicial, a confiança é constantemente reavaliada.

- Monitorização: As empresas devem monitorizar e medir continuamente a postura de segurança e a integridade de todos os ativos associados, garantindo o registo (logging) e a reavaliação do estado das comunicações e infraestruturas.

- Mecanismos Matemáticos: A avaliação de confiança recorre a algoritmos avançados, como machine learning e lógica difusa, para recalcular dinamicamente os níveis de risco.

### Domínios de aplicação 
- A aplicação do modelo ZTA é particularmente relevante em setores críticos e tecnologias emergentes, tais como:
  - Sistemas de cuidados de saúde.

  - Infraestruturas de redes 5G/6G.

  - Ecossistemas de Internet das Coisas (IoT).

  - Ambientes de Metaverso.

### Desafios de implementação 
- Apesar das suas vantagens claras, a adoção do ZTA depara-se com barreiras consideráveis:
  - O aumento da latência na rede derivado dos processos de verificação contínua.

  - A dificuldade em integrar estes novos paradigmas com sistemas legados.

  - A elevada complexidade associada à gestão de políticas de acesso tão dinâmicas e granulares.
