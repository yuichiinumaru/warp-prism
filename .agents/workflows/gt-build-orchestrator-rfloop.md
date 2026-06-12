1. Escolha os subagents mais adequados para as tasks indo no .agents/index-agents.md - só use estes agents, não use general task.

2. Lance um reviewer para cada 2 tasks: apenas mande ele seguir o .agents/workflows/gt-build-review.md usar as skills code-quality-harness e flutter-harness, para revisar as tasks nnnn e nnnn. Não precisa falar mais nada, o workflow + skills deve cobrir tudo

3. Per workflow eles devem assinalar um score: 
	S >= 90 = Aprovado => **Subagent Reviewer aplica patch para chegar a 100 e move a tarefa para 03-review;**
	S < 90 = Rejeitado => Reviewer deixa nota de rodapé justificando o score e sugestão de path to 100; 
		=> Mande agentes para aplicar os fixes nas tasks rejeitadas desta forma. 
		=> Ao finalizar, lance de novo o review, e faz isso até o score sair 100. 

OBS: Toda task que foi pra fix tem que ser revisada de novo por um subagent reviewer (considere um builder-reviewer), mesmo que o fixer agent alegue que executou o path to 100. **Enquanto não sair com score 100 por mão do reviewer, não passa para 03-review. Lembre sempre: Zero tolerance, zero guesswork. Trabalhamos com provas e contratos.** Não existe número máximo de rounds para ir e voltar de review. É até ficar perfeito = score 100. Os arquivos de Tasks NÃO SAEM de 02-doing enquanto elas não estiverem prontas de fato pra ir pra 03-review (NUNCA direto para 04-COMPLETED). Esta etapa de revisão é interna da lane de build, pra não mandar task feita pela metade pro reviewer. NÃO EXISTE pular o parallel-review e mandar task fixed direto pra 03-review, NÃO EXISTE "já passou por vários cíclos de correção", NÃO EXISTE "acho que tá bom". O critério é numérico; subagent reviewer deu score 90 ou mais, ELE move pra 03-review; Menos, manda subagent fixer de novo. Sem discussão.
**Subagents não-reviewers NÃO movem tasks pra 03-review.**
**Subagents não rodam rebuild de tasklist nem de changelog.** Só você orchestrator roda, no final da wave, SE houver progresso real (tasks foram pra review).

4. Repete o ciclo até acabar todas as tarefas da lista, na ordem definida, autonomamente
- Só pare se acabar as tasks ou se tiver um blocker real e precisar de orientação, por exemplo em tomada de decisão arquitetural.
- Você não pega tasks, apenas delega subagents especializados para cumprir a task, depois em review em paralelo, depois subagents de fix
- Entre terminar um parallel-review e mandar a próxima wave de build, sempre analise o ping pong review-fix e verifique se cabe upgrade em alguma das principais skills que tem sido utilizadas. Anote isso num documento em docs/reports/builders/harness-upgrades.md
