<cfscript>
component alias="services.basics.BasicsController" name="services.basics.BasicsController" 
{
	this.dao = new services.basics.BasicsDAO();

	this.ip = 'localhost';
	this.user_agent = 'localhost';

	public string function sendBasicsInformation (string guid,
												  numeric cpf_cnpj,
												  string name,
												  string email,
												  string ddd,
												  string phone_number)
	{
		this.dao.sendBasicsInformation (guid, 
									 	cpf_cnpj, 
									 	name, 
									 	email, 
									 	ddd, 
									 	phone_number,
									 	this.ip,
									 	this.user_agent);
	};

}
</cfscript>