.PHONY: pipeline cost metabase lint lint-py lint-sql

pipeline:
	python pipeline.py

cost:
	python cost_report.py

metabase:
	docker run -d -p 3000:3000 --name metabase metabase/metabase

lint: lint-py lint-sql

lint-py:
	ruff check pipeline.py cost_report.py

lint-sql:
	sqlfluff lint sql/ --dialect bigquery
