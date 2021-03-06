USE py_test;

DROP TABLE IF EXISTS #temp;
SELECT ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY pay_dt) AS row,CAST(NULL AS DATE) AS exit_date,
CAST(NULL AS INT) AS balance, CAST(NULL AS DATE) AS global_until_date,
* INTO #temp FROM payments;

--?????????? ????????, ??? ?????
DROP TABLE IF EXISTS #clients
SELECT row_number() OVER (ORDER BY client_id) as row, client_id INTO #clients FROM #temp GROUP BY client_id;

DECLARE @max_client_iterator INT = (SELECT count(client_id) FROM #clients), @client_iterator INT = 1
,@client_id VARCHAR(5), @cl_serv_iterator INT, @max_cl_serv_iterator INT, @service_id INT, @balance1 INT = 0,
@until_date1 DATE, @pay_dt1 DATE, @balance2 INT = 0, @until_date2 DATE, @pay_dt2 DATE, @balance3 INT = 0,
@until_date3 DATE, @pay_dt3 DATE, @service1_row INT, @service2_row INT, @service3_row INT, @global_next DATE,
@@global_until_date DATE;

WHILE (@client_iterator <= @max_client_iterator)
BEGIN
	SET @client_id = (SELECT client_id FROM #clients WHERE row = @client_iterator);

	SET @cl_serv_iterator = 1;
	SET @max_cl_serv_iterator  = (SELECT count(row) FROM #temp WHERE client_id = @client_id);

	WHILE (@cl_serv_iterator <= @max_cl_serv_iterator)
	BEGIN
		--SELECT * FROM #temp WHERE client_id = @client_id;
		--SELECT * FROM #temp WHERE client_id = @client_id AND row = @cl_serv_iterator;
		SET @service_id =(SELECT service_id FROM #temp WHERE client_id = @client_id AND row = @cl_serv_iterator);

		--? ?????? service_id ?????????? ???,? ???????? ?? ?????????? ?????????? service_id, + ?????????? ??????????, ??????? ??????? ? ??????? 
		--??? ????????? ????? ???????????? ????????? ?????????? ??? ??????? (10 ???? ??????? ?????? ????(?? ????? ???????? ? ???? ???))

		--??? ?????????? ??????? ?? ???????. ? ??????? ???????????? ? ?????????? ?????? ???????. ??? ?????? ?????? = NULL		
		SET @@global_until_date = (SELECT global_until_date FROM #temp WHERE client_id = @client_id AND row = @cl_serv_iterator);
		IF @service_id = 1
		BEGIN										
				SET @pay_dt1 = (SELECT pay_dt FROM #temp WHERE client_id = @client_id AND row = @cl_serv_iterator);
				--?????? ????????? ???????, ??????? ? ????????? ?????? ??????-??????? + ??? ???????????? ??????
				SET @balance1 = 0;
				SET @balance1 = 10 - DATEDIFF(DAY, (SELECT pay_dt FROM #temp WHERE client_id = @client_id AND row = @service1_row), @pay_dt1) + (SELECT balance FROM #temp WHERE client_id = @client_id AND row = @service1_row);
				SET @service1_row = @cl_serv_iterator;
				IF @balance1 < 0 OR @balance1 IS NULL
					SET @balance1 = 0;
				UPDATE #temp SET balance = @balance1 WHERE client_id = @client_id AND row = @cl_serv_iterator;
				--???????? ???? ?????? ??????-?? ??????? ???????
				IF (@cl_serv_iterator = @max_cl_serv_iterator)
					SET @global_next = CAST(NULL AS DATE);
				ELSE
					SET @global_next = (SELECT pay_dt FROM #temp WHERE client_id = @client_id AND row = (@cl_serv_iterator + 1));
				--???????????? ?????????????? ???? ?????????? ???????? ? ?????? ???????
				SET @until_date1 = DATEADD(DAY, 10 + @balance1, @pay_dt1);
				PRINT (@until_date1);
				IF @until_date1 <= @@global_until_date
					SET @until_date1 = @@global_until_date
				IF DATEADD(DAY, 10, @until_date1) <= @global_next OR @cl_serv_iterator = @max_cl_serv_iterator
					UPDATE #temp SET exit_date = @until_date1 WHERE client_id = @client_id AND row = @cl_serv_iterator;
				IF @cl_serv_iterator != @max_cl_serv_iterator
					UPDATE #temp SET global_until_date = @until_date1 WHERE client_id = @client_id AND row = (@cl_serv_iterator +1);
		END
		IF @service_id = 2
		BEGIN
				SET @pay_dt2 = (SELECT pay_dt FROM #temp WHERE client_id = @client_id AND row = @cl_serv_iterator);
				--?????? ????????? ???????, ??????? ? ????????? ?????? ??????-??????? + ??? ???????????? ??????
				SET @balance2 = 0;
				SET @balance2 = 20 - DATEDIFF(DAY, (SELECT pay_dt FROM #temp WHERE client_id = @client_id AND row = @service2_row), @pay_dt2) + (SELECT balance FROM #temp WHERE client_id = @client_id AND row = @service2_row);
				SET @service2_row = @cl_serv_iterator;
				IF @balance2 < 0 OR @balance2 IS NULL
					SET @balance2 = 0;
				UPDATE #temp SET balance = @balance2 WHERE client_id = @client_id AND row = @cl_serv_iterator;
				--???????? ???? ?????? ??????-?? ??????? ???????
				IF (@cl_serv_iterator = @max_cl_serv_iterator)
					SET @global_next = CAST(NULL AS DATE);
				ELSE
					SET @global_next = (SELECT pay_dt FROM #temp WHERE client_id = @client_id AND row = (@cl_serv_iterator + 1));
				--???????????? ?????????????? ???? ?????????? ???????? ? ?????? ???????
				SET @until_date2 = DATEADD(DAY, 20 + @balance2, @pay_dt2);
				PRINT (@until_date2);
				IF @until_date2 <= @@global_until_date
					SET @until_date2 = @@global_until_date
				IF DATEADD(DAY, 10, @until_date2) <= @global_next OR @cl_serv_iterator = @max_cl_serv_iterator
					UPDATE #temp SET exit_date = @until_date2 WHERE client_id = @client_id AND row = @cl_serv_iterator;
				IF @cl_serv_iterator != @max_cl_serv_iterator
					UPDATE #temp SET global_until_date = @until_date2 WHERE client_id = @client_id AND row = (@cl_serv_iterator +1);
				
				

				--print(1)
		END
		IF @service_id = 3
		BEGIN
				SET @pay_dt3 = (SELECT pay_dt FROM #temp WHERE client_id = @client_id AND row = @cl_serv_iterator);
				--?????? ????????? ???????, ??????? ? ????????? ?????? ??????-??????? + ??? ???????????? ??????
				SET @balance3 = 0;
				SET @balance3 = 40 - DATEDIFF(DAY, (SELECT pay_dt FROM #temp WHERE client_id = @client_id AND row = @service3_row), @pay_dt3) + (SELECT balance FROM #temp WHERE client_id = @client_id AND row = @service3_row);
				SET @service3_row = @cl_serv_iterator;
				IF @balance3 < 0 OR @balance3 IS NULL
					SET @balance3 = 0;
				UPDATE #temp SET balance = @balance3 WHERE client_id = @client_id AND row = @cl_serv_iterator;
				--???????? ???? ?????? ??????-?? ??????? ???????
				IF (@cl_serv_iterator = @max_cl_serv_iterator)
					SET @global_next = CAST(NULL AS DATE);
				ELSE
					SET @global_next = (SELECT pay_dt FROM #temp WHERE client_id = @client_id AND row = (@cl_serv_iterator + 1));
				--???????????? ?????????????? ???? ?????????? ???????? ? ?????? ???????
				SET @until_date3 = DATEADD(DAY, 40 + @balance3, @pay_dt3);
				PRINT (@until_date3);
				IF @until_date3 <= @@global_until_date
					SET @until_date3 = @@global_until_date
				IF DATEADD(DAY, 10, @until_date3) <= @global_next OR @cl_serv_iterator = @max_cl_serv_iterator
					UPDATE #temp SET exit_date = @until_date3 WHERE client_id = @client_id AND row = @cl_serv_iterator;
				IF @cl_serv_iterator != @max_cl_serv_iterator
					UPDATE #temp SET global_until_date = @until_date3 WHERE client_id = @client_id AND row = (@cl_serv_iterator +1);
		END
		--IF @cl_serv_iterator =2
		--BREAK;

		SET @cl_serv_iterator +=1;
	END
	--IF @client_iterator = 1
	--BREAK;

	SET @client_iterator +=1;
END

SELECT * FROM #temp; --???????? ??????? ? ?????????????? ???????? ?? ????????.

DROP TABLE IF EXISTS final;
SELECT DISTINCT
YEAR(exit_date) AS y
,MONTH(exit_date) AS m
,client_id
INTO final
FROM #temp
WHERE exit_date IS NOT NULL;

DROP TABLE IF EXISTS finish;

SELECT DISTINCT
y
,m
,Count(client_id) OVER (PARTITION BY y, m) AS exits_by_clients
INTO finish
FROM final

SELECT * FROM finish;