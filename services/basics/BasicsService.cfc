<cfscript>
component alias="services.basics.BasicsService" name="services.basics.BasicsService" 
{

	remote struct function test() returnformat="json"
	{
		var result = structNew();
		try
		{
			result["result"] =  "Welcome to my world"
			result["success"] = true;
		}
		catch (any e)
		{
			result["success"] = false;
			result["errormessage"] = e.message;
			result["errorcode"] = e.errorcode;
			result["stacktrace"] = e.stacktrace;
		};
		return result;
	};

}
</cfscript>