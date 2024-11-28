# BPA Rules in Looping

Esse script roda o bpa rules para todos os modelos em uma lista de servidores.<br>
a lista pode conter tanto servidores analysis services quanto workspaces do powerbi<br>
a identidade gerenciada precisa ter acesso a todos os servidores na lista.<br>
para gravação dos nomes removemos os acentos colchetes e espaços, então se tiver dois modelos muito parecidos teremos duplicidade:<br>
Model Name1 --> modelname1<br>
Model [Name] 1 --> modelname1<br>
