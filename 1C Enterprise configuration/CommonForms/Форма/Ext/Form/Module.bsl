﻿
&НаКлиенте
Процедура Тест(Команда)
	ТестНаСервере();
КонецПроцедуры

&НаСервере
Процедура ТестНаСервере()
	
	Токен = "Ваш_токен";
	
	Заголовки = Новый Соответствие;                                                                   
	Заголовки.Вставить("Content-Type", "application/json; charset=utf-8");
	Заголовки.Вставить("Authorization", "Bearer " + Токен);
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("Заголовки", Заголовки);
	ДополнительныеПараметры.Вставить("Данные", "{}");
	
	// GetInfo - Получение информации о пользователя.
	Адрес = "https://invest-public-api.tinkoff.ru/rest/tinkoff.public.invest.api.contract.v1.UsersService/GetInfo";
	
	Результат = КоннекторHTTP.Post(Адрес, Неопределено, ДополнительныеПараметры);
	Если Результат.КодСостояния <> 200 Тогда
		Возврат;
	КонецЕсли;
	
	ИнформацияОПользователе = КоннекторHTTP.КакТекст(Результат);
	Журнал.ДобавитьСтроку(ИнформацияОПользователе + Символы.ПС);

	// GetAccounts - Получение списка счетов пользователя. 
    Адрес = "https://invest-public-api.tinkoff.ru/rest/tinkoff.public.invest.api.contract.v1.UsersService/GetAccounts";
	Результат = КоннекторHTTP.Post(Адрес, Неопределено, ДополнительныеПараметры);
	Если Результат.КодСостояния <> 200 Тогда
		Возврат;
	КонецЕсли;
	
	ДанныеСчетовКлиента = КоннекторHTTP.КакJson(Результат);
	Счета = ДанныеСчетовКлиента.Получить("accounts");
	
	Для каждого Счет Из Счета Цикл
		
		ИдентификаторСчета = Счет.Получить("id");
		ИмяСчета = Счет.Получить("name");
		СтатусСчета = Счет.Получить("status");
		
		Журнал.ДобавитьСтроку(СтрШаблон("ID: %1 %2 %3", ИдентификаторСчета, ИмяСчета, СтатусСчета));
	
	КонецЦикла;
	
	// GetPortfolio - Получение портфолио.
	Адрес = "https://invest-public-api.tinkoff.ru/rest/tinkoff.public.invest.api.contract.v1.OperationsService/GetPortfolio";   
	
	ИтоговаяСтоимость = 0;
	Для каждого Счет Из Счета Цикл
		
		ДополнительныеПараметры.Данные = КоннекторHTTP.ОбъектВJson(Новый Структура("accountId", Счет.Получить("id")));
		
		Результат = КоннекторHTTP.Post(Адрес, Неопределено, ДополнительныеПараметры); 
		Если Результат.КодСостояния <> 200 Тогда
			Возврат;
		КонецЕсли;
		
		ДанныеСчета = КоннекторHTTP.КакJson(Результат);
		
		ОбщаяСтоимостьАкций = Число(ДанныеСчета.Получить("totalAmountShares").Получить("units"));
		ОбщаяСтоимостьОблигаций = Число(ДанныеСчета.Получить("totalAmountBonds").Получить("units"));
		ОбщаяСтоимостьФондов = Число(ДанныеСчета.Получить("totalAmountEtf").Получить("units"));
		ОбщаяСтоимостьВалют = Число(ДанныеСчета.Получить("totalAmountCurrencies").Получить("units"));
		ОбщаяСтоимостьФьючерсов = Число(ДанныеСчета.Получить("totalAmountFutures").Получить("units"));
		
		ИтоговаяСтоимость = ИтоговаяСтоимость + ОбщаяСтоимостьАкций + ОбщаяСтоимостьОблигаций + ОбщаяСтоимостьФондов + ОбщаяСтоимостьВалют + ОбщаяСтоимостьФьючерсов;  
	
	КонецЦикла;
	
	Журнал.ДобавитьСтроку(ИтоговаяСтоимость);
	
КонецПроцедуры
