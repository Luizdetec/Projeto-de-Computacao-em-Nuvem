# Projeto de Computação em Nuvem - Chat em Tempo Real

Projeto prático da disciplina de **Programação Paralela e Distribuída** do curso de Ciência da Computação do CESUPA. O objetivo foi projetar, implementar e documentar uma solução de sistema distribuído utilizando conceitos de computação em nuvem, infraestrutura como código e comunicação entre processos.

## Alunos

* Luiz Eduardo Estrella Alvares
* Renan Rodrigues Moreira
* Leonardo de Medeiros Bernardes

## Descrição do Projeto

Este projeto consiste em uma aplicação de chat em tempo real. A aplicação permite que múltiplos usuários se conectem a um servidor central e troquem mensagens que são retransmitidas a todos os participantes da sala instantaneamente.

A infraestrutura é provisionada de forma automatizada na nuvem da AWS utilizando Terraform, e a comunicação entre cliente e servidor é feita via Sockets, com a biblioteca Socket.IO.

## Arquitetura da Solução

A arquitetura de nuvem foi projetada para ser simples e funcional, contendo os seguintes componentes na AWS:

* **VPC (Virtual Private Cloud):** Ambiente de rede isolado para hospedar os recursos.
* **Sub-rede Pública:** Permite que os recursos se comuniquem com a internet.
* **Internet Gateway:** Fornece acesso à internet para a VPC.
* **Tabela de Rotas:** Direciona o tráfego da sub-rede para o Internet Gateway.
* **Grupo de Segurança:** Atua como um firewall virtual, liberando apenas as portas necessárias (porta `3000` para a aplicação e `22` para acesso SSH).
* **Instância EC2:** Servidor virtual (Linux Ubuntu) onde a aplicação Node.js é executada. A instância é configurada automaticamente no boot através de um script `user_data`.

## Tecnologias Utilizadas

* **Provedor de Nuvem:** Amazon Web Services (AWS)
* **Infraestrutura como Código (IaC):** Terraform 
* **Backend:** Node.js com Express.js
* **Comunicação em Tempo Real:** Sockets via Socket.IO 
* **Linguagem da Aplicação:** JavaScript (Node.js)
* **Linguagem da Infraestrutura:** HCL (HashiCorp Configuration Language)

## Instruções de Execução

Siga os passos abaixo para testar a aplicação localmente ou para provisionar a infraestrutura completa na AWS.

### Pré-requisitos

* Possuir uma conta ativa na AWS.
* [Node.js](https://nodejs.org/) (versão LTS) instalado.
* [Terraform](https://www.terraform.io/downloads) instalado.
* [AWS CLI](https://aws.amazon.com/cli/) instalado e configurado.

### 1. Execução Local

Para testar a aplicação em sua máquina sem usar a nuvem:

1.  Clone o repositório:
    ```bash
    git clone <URL_DO_SEU_REPOSITORIO>
    cd <NOME_DO_REPOSITORIO>/app
    ```

2.  Instale as dependências do Node.js:
    ```bash
    npm install
    ```

3.  Inicie o servidor local:
    ```bash
    node server.js
    ```

4.  Abra seu navegador e acesse `http://localhost:3000`.

### 2. Deploy na Nuvem (AWS)

Para provisionar toda a infraestrutura e rodar a aplicação na AWS:

1.  Clone o repositório (se ainda não o fez):
    ```bash
    git clone <URL_DO_SEU_REPOSITORIO>
    cd <NOME_DO_REPOSITORIO>
    ```
    **IMPORTANTE:** Certifique-se de que a URL do seu repositório Git está correta no arquivo `terraform/main.tf` na linha do `user_data`.

2.  Configure suas credenciais da AWS no terminal:
    ```bash
    aws configure
    ```
    Insira sua `Access Key ID`, `Secret Access Key` e região padrão (ex: `us-east-1`).

3.  Navegue até a pasta do Terraform e inicialize-o:
    ```bash
    cd terraform
    terraform init
    ```

4.  Aplique o plano para criar a infraestrutura:
    ```bash
    terraform apply
    ```
    O Terraform exibirá o plano de execução. Digite `yes` e pressione Enter para confirmar.

5.  Ao final do processo, o Terraform exibirá o IP público da instância criada (`instance_public_ip`). Abra seu navegador e acesse: `http://<IP_PUBLICO_DA_INSTANCIA>:3000`.

### 3. Destruindo a Infraestrutura

**AVISO:** Após concluir os testes e a avaliação, é crucial destruir toda a infraestrutura para evitar cobranças da AWS.

1.  Na pasta `terraform`, execute o comando:
    ```bash
    terraform destroy
    ```
2.  Confirme digitando `yes`.