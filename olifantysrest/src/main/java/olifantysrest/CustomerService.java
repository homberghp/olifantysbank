package olifantysrest;

import java.math.BigDecimal;
import jsonutil.JSONType;
import javax.annotation.Resource;
import javax.ejb.Stateless;
import javax.json.JsonObject;
import javax.sql.DataSource;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import jsonutil.JSONQueryService;

/**
 *
 * @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
 */
@Stateless
@Path( "customer" )
public class CustomerService {

    @Resource( lookup = "jndi:jdbc/olifantys" )
    DataSource ds;
    JSONQueryService jqs = new JSONQueryService();

    /**
     * Create a customer account. 
     * @param cid the customer for the account
     * @param job the json object containing the the description plus the initial balance. 
     * @return the account data as json 
     */
    @POST
    @Consumes( { MediaType.APPLICATION_JSON } )
    @Produces( { MediaType.APPLICATION_JSON } )
    @Path( "{cid}/create_account" )
    public String create( @PathParam( "cid" ) int cid, String job) {
        String query ="select * from createaccount(?,?,?)";
        JsonObject json=jqs.stringToJson( job );
        BigDecimal initBalance = new BigDecimal(json.getString("balance" ));
        String desc = json.getString( "description");
        return jqs.queryToJsonString( ds, query, JSONType.JSONOBJECT, cid, initBalance, desc );
    }

    @GET
    @Consumes( { MediaType.APPLICATION_JSON } )
    @Produces( { MediaType.APPLICATION_JSON } )
    @Path( "{cid}/account/{aid}" )
    public String getAccount( @PathParam( "cid" ) int cid, @PathParam( "aid" ) int aid ) {

        String query = "select * from account where customerid=? and accountid=?";
        return jqs.queryToJsonString( ds, query, JSONType.JSONOBJECT, cid, aid );

    }

    @GET
    @Produces( { MediaType.APPLICATION_JSON } )
    public String getAllAccounts() {
        String query = "select * from account";
        return jqs.queryToJsonString( ds, query, JSONType.JSONARRAY );

    }

    @GET
    @Produces( { MediaType.APPLICATION_JSON } )
    @Path("{cid}/account")
    public String getCustomerAccounts( @PathParam("cid") int cid ) {
        String query = "select * from account where customerid=?";
        return jqs.queryToJsonString( ds, query, JSONType.JSONARRAY, cid );
    }

    @GET
    @Produces( { MediaType.APPLICATION_JSON } )
    @Path("{cid}")
    public String getCustomer( @PathParam("cid") int cid ) {
        String query = "select * from customer where customerid=?";
        return jqs.queryToJsonString( ds, query, JSONType.JSONARRAY, cid );
    }
    
    @GET
    @Produces( { MediaType.APPLICATION_JSON } )
    @Path("{cid}/account/{aid}/transactions")
    public String getAccountTransactions( @PathParam("cid") int cid, @PathParam("aid") int aid ) {
        String query = "select * from mytransactions  trans join account using(accountid)  where customerid=? and accountid=?";
        return jqs.queryToJsonString( ds, query, JSONType.JSONARRAY, cid,aid );
    }
    
}
