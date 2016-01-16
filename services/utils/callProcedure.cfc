<cfscript>
component alias="services.utils.callProcedure" name="services.utils.callProcedure" 
{
	OracleTypes = createObject("java", "oracle.jdbc.OracleTypes");
	DriverManager = createObject("java", "java.sql.DriverManager");
	OracleDriver = createObject("java", "oracle.jdbc.driver.OracleDriver");

	this.dbUrl = "jdbc:oracle:thin:@//localhost:8888/xpto_dev";
	this.dbUser = "XPTO_CONNECT";
	this.dbPwd = "xpto321#@!#";

	private any function geConnection ()
	{
		DriverManager.registerDriver(OracleDriver.init());
		return DriverManager.getConnection(this.dbUrl, this.dbUser, this.dbPwd);
	};

	/* EXAMPLE 
		
		var method = "package.procedure";
		
		var args = [arg1, arg2, arg3];

		var outs = [{"variable_name":"p_cursor","variable_type":"CURSOR"},
					{"variable_name":"vs_message","variable_type":"VARCHAR"}];

		return callProcedure(msg,args,outs);
	
	*/

	private array function callProcedure (string method, 
										  array args, 
										  array outs)
	{
		try
		{
			var orDb = getConnection();
			var named = arrayNew(1);
			var sqlCallOracle = "{call " & method & "(";

			for (var k = 1; k <= arrayLen(args); k++)
			{
				arrayAppend(named, ":arg" & k);
			};

			for (var k = 1; k <= arrayLen(outs); k++)
			{
				arrayAppend(named, ":" & outs[k].variable_name);
			};

			sqlCallOracle &= arrayToList(named, ", ")&")}";
			
			var stmt = orDb.prepareCall(sqlCallOracle);

			for (var k = 1; k <= arrayLen(args); k++)
			{
				stmt.setObject("arg" & k, args[k]);
			};

			for (var k = 1; k <= arrayLen(outs); k++)
			{
				if(outs[k].variable_type == "CURSOR")
				{
					stmt.registerOutParameter(outs[k].variable_name, OracleTypes.CURSOR);
				}
				else if(outs[k].variable_type == "VARCHAR")
				{
					stmt.registerOutParameter(outs[k].variable_name, OracleTypes.VARCHAR);
				}
				else
				{
					throw "Tipo de variável de saída não implementada";
				};
			};

			stmt.execute();
			
			var result = structNew();

			for (var k = 1; k <= arrayLen(outs); k++)
			{
				if(outs[k].variable_type == "CURSOR")
				{
					var rs = stmt.getObject(outs[k].variable_name);

					var data = rs.getMetaData();
					var count = data.getColumnCount();
					var resultItem = arrayNew(1);
					
					while (rs.next())
					{
						var obj = structNew();

						for (var k = 1; k <= count; k++)
						{
							var name = lcase(data.getColumnName(k));
							obj[name] = rs.getObject(name);
						};

						arrayAppend(resultItem, obj);
					};
					
					rs.close();

					result[outs[k].variable_name] = resultItem;
				}
				else
				{
					throw "Tipo de variável de saída não implementada";
				};
			};

			stmt.close();

            return result;
		}
		catch (any e)
		{
			throw(object=e);
		}
		finally
		{
			orDb.close();
		};
	};
}
</cfscript>
