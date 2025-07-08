# Tuneboard 🎶

**Tuneboard** é um brinquedo musical educacional com hardware integrado ao iOS, projetado para tornar a criação de música uma experiência interativa e divertida.


## Brinquedo musical integrado ao iPhone

O usuário posiciona **cards físicos** na mesa Tuneboard para montar sua música.  
Cada card representa uma trilha de áudio ou um efeito (Acelerar, Desacelerar, Pitch, Reverb).  
O iPhone pareado via Bluetooth Low Energy (BLE) detecta os cards em tempo real e aplica as modificações de áudio instantaneamente.

![ScreenRecording_07-07-202513-56-55_1-ezgif com-cut](https://github.com/user-attachments/assets/7e549d7c-6528-4493-b172-be7f9cb7577d)



## Funcionalidades principais 

- **Mesa interativa de cards**: arraste e solte trilhas de áudio em qualquer posição.  
- **Efeitos em tempo real**: Acelerar/Desacelerar, Pitch, Reverb.  
- **Processamento nativo**: toda a lógica de áudio roda no iPhone, preservando performance e bateria.  
- **Pareamento nativo**: experiência equivalente a de acessórios Apple, usando Accessory Setup Kit (ASK).  


## Como funciona? 

1. **Ligação do dispositivo**  
   - O ESP32-C6 emite beacon BLE; o app iOS se conecta automaticamente (ASK).  
2. **Leitura dos cards**
  
   - Cada card possui identificação única coordenada pelo ESP, ao aproximar da mesa, o iPhone interpreta qual trilha/efeito ativar.  
3. **Processamento de Áudio**  
   - Usando AVFoundation, o app faz mixagem e aplica efeitos em tempo real, com cache inteligente para reduzir uso de memória.  
4. **Interação contínua**  
   - Mova, adicione ou remova cards a qualquer momento; o áudio se ajusta instantaneamente.

## Tecnologias utilizadas 🛠

| Tecnologia                     | Propósito                                      |
| ------------------------------ | ----------------------------------------------- |
| `Swift`                        | Lógica do app iOS e BLE                         |
| `SwiftUI`                      | Interface de usuário                            |
| `AVFoundation`                 | Processamento e mixagem de áudio                |
| `Accessory Setup Kit (ASK)` + `CoreBluetooth`  | Pareamento Bluetooth nativo                     |
| `ESP32-C6` + `ESP-IDF` | Firmware para leitura de cards e comunicação BLE|

## Sobre mim

<p align="center">
  <img src="https://github.com/user-attachments/assets/e4d42b51-c879-4839-8b9d-e7e265bc923b" alt="Logo Otávio" width="200"/>
    <img src="https://github.com/user-attachments/assets/397d59c1-3b36-466c-8de4-d24230c48eed" alt="Otávio" width="200"/>

</p>

Olá! Sou Otávio Augusto, estudante de Engenharia de Software e desenvolvedor iOS apaixonado por design, hardware e experiências diferenciadas de software! Te convido a conhecer meu portifolio :) 

<div align="center">
  <a href="https://github.com/otavioaugustosw/TuneBoard" target="_blank">
    <img src="https://img.shields.io/badge/-GitHub-181717?style=for-the-badge&logo=github&logoColor=white"/>
  </a>
  <a href="https://www.linkedin.com/in/otavio-augusto-silva/" target="_blank">
    <img src="https://img.shields.io/badge/-LinkedIn-%230077B5?style=for-the-badge&logo=linkedin&logoColor=white"/>
  </a>
      <a href="https://www.otavioaugustosw.com" target="_blank"><img src="https://img.shields.io/badge/Portfolio-255E63?style=for-the-badge&logo=About.me&logoColor=white" target="_blank"></a> 
</div>
