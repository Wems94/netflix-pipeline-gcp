# MovieLens Beliefs Dataset 2024 — Documentação

## Resumo

Dataset com recomendações, avaliações e "crenças" (ratings esperados sobre filmes não assistidos) dos usuários do MovieLens.

- **Período de coleta:** 1º de março de 2023 até 1º de maio de 2024
- **Atualização:** 8 de fevereiro de 2025 (versão 2 — usada neste projeto)
- **Download:** https://grouplens.org/datasets/movielens/ml_belief_2024/

---

## Arquivos do Dataset

| Arquivo | MD5 | Descrição |
|---|---|---|
| `movies.csv` | a0ff36b2c08e86316862d30b6d01963d | Informações dos filmes |
| `user_rating_history.csv` | c822b8611e9767d198f812d4a678524c | Histórico de avaliações dos usuários |
| `belief_data.csv` | ec2c04e47cc2c2491d1427959a34f329 | Dados de crenças elicitadas |
| `movie_elicitation_set.csv` | 8ce2e6f3414979ca56b3d0cc09670afe | Set de filmes para elicitação |
| `user_recommendation_history.csv` | 326b2c0ee4ccb0455b949e4dd7544032 | Histórico de recomendações |

---

## Estrutura dos Arquivos

### movies.csv
```
movieId, title, genres
```
- Gêneros separados por pipe `|`
- Títulos podem conter o ano de lançamento entre parênteses ex: `Toy Story (1995)`

### user_rating_history.csv
```
userId, movieId, rating, timestamp
```
- Escala de 0.5 a 5.0 estrelas (incrementos de 0.5)
- Timestamp em segundos desde 1970-01-01 UTC

### belief_data.csv
```
userId, movieId, isSeen, watchDate, userElicitRating, userPredictRating, userCertainty, tstamp, month_idx, source, systemPredictRating
```
- `isSeen`: -1 (sem resposta), 0 (não assistiu), 1 (assistiu)
- `userElicitRating`: rating real (só se isSeen = 1)
- `userPredictRating`: rating esperado (só se isSeen = 0)
- `userCertainty`: certeza do rating esperado, escala 1.0 a 5.0 (só se isSeen = 0)

### movie_elicitation_set.csv
```
movieId, month_idx, source, tstamp
```
- `source`: 1=Popularidade, 2=Rating, 3=Lançamentos populares, 4=Lançamentos em alta, 5=Serendipidade

### user_recommendation_history.csv
```
userId, tstamp, movieId, predictedRating
```
- Recomendações observadas pelos usuários com rating previsto pelo sistema

---

## Gêneros disponíveis

Action, Adventure, Animation, Children's, Comedy, Crime, Documentary, Drama, Fantasy, Film-Noir, Horror, Musical, Mystery, Romance, Sci-Fi, Thriller, War, Western, (no genres listed)

---

## Verificação de Integridade (após descompactar)

```bash
# macOS
md5 *; cat checksums.txt
```

---

## Licença de Uso

- Uso permitido para pesquisa
- Não pode ser usado para fins comerciais sem autorização
- Deve citar o paper: *Guy Aridor et al. 2024. The MovieLens Beliefs Dataset*
- Contato: grouplens-info@umn.edu
