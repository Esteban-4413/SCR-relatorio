# Notas de pesquisa


## O que é Zero Trust Architecture

### First source (youtube video)
[What Is Zero Trust Architecture (ZTA) ? NIST 800-207 Explained](https://www.youtube.com/watch?v=5Kq64vOgE10)

#### The basics
Zero trust principles 
- Never trust, always berify
- After trust; constantly re-asses
- No concept of internet or external users 

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

This seven tentants must remain true for any implementation to accomplish a zero-trust architecture

