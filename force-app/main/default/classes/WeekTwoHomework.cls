public with sharing class WeekTwoHomework {
    public static void AccountNameAndIndustry() {
        List<Contact> energyContactsWithAccountInfo = [SELECT Name, Account.Name, Account.Industry FROM Contact WHERE Account.Industry = 'Energy' LIMIT 10];
        for(Contact con : energyContactsWithAccountInfo){
            System.debug('Contact: '+ con.Name + ', ' + 'Account: ' + con.Account.Name);
        }
    }
    
    public static void AccountsWithClosedWonOpps () {
        List <Account> acctsWonOpps = [SELECT Name, (SELECT Name FROM Opportunities WHERE StageName = 'Closed Won') FROM Account];
        /*'Opportunities' really tripped me up here, because I wasn't aware of the convention to pluralize child records in a subquery. Maybe I missed this in class, but this was the hardest part of the HW for me. I'm not sure if I'm fully understanding why, beyond the relationship between child to parent being many to one and parent to child being one to many...?
/*SF Doc link: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_relationships_and_custom_objects.html */
        for (Account acc : acctsWonOpps){
            for (Opportunity opp: acc.Opportunities){
                System.debug ('Account: '+ acc.Name + ', ' + 'Opportunity: ' + opp.Name);
            }
            //I broke the process up into two loops here because the subquery returned a different object type from the parent query
            /*I really wanted to get this debug statement to print the Account name once with multiple Opportunities listed for the single Account, but couldn't figure it out. I think I'd need to use a set, and then maybe a for loop to check whether the account Id has been printed, print it and add the id to the set if it's not already there? I couldn't get it to work right, and I ran out of steam before I could figure it out
*/
        }
    }   
    
    public static void partnerOppAmount (){
        Map < Id, Opportunity > partnerOppAmount = new Map < Id, Opportunity >([
            SELECT Id, Name, Amount 
            FROM Opportunity 
            WHERE LeadSource = 'Partner'
        ]);
        //debug statement for testing whether my query was working
        for (Opportunity opp : partnerOppAmount.values()){
            System.debug(opp);
        }
    }
    
    public static void aggregateOpps (){
        Integer totalOppsCount = [
            SELECT COUNT() 
            FROM Opportunity 
            WHERE IsClosed = FALSE
            OR IsWon = FALSE
        ];
        //I was trying to avoid the negative filter antipattern, and it felt inefficient to use OR and cycle through every list option. Is it ok to specifically look for FALSE values since it's Boolean and not negative? I'm not sure I'm fully understanding the difference.
        System.debug('There are '+ totalOppsCount + ' Open Opportunities in the Dev Environment');
    }
}

