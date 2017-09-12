package olifantysrest;

import java.net.URI;
import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.ejb.Stateless;
import javax.sql.DataSource;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriInfo;
import jsonutil.JSONQueryService;
import olifantysdb.Teller;

/**
 *
 * @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
 */
@Stateless
@Path( "teller" )
public class TellerEndpoint {
    
    @Resource( lookup = "jndi:jdbc/teller" )
    DataSource ds;
    Teller teller;
    @PostConstruct
    public void init(){
        teller = new Teller(ds);
    }
    @POST
    @Consumes( { MediaType.APPLICATION_JSON } )
    @Produces( { MediaType.APPLICATION_JSON } )
    @Path( "transfer" )
    public Response transfer( String job, @Context UriInfo info ) {
        System.out.println( "job = " + job );
        String qr = teller.transfer( job );
        int transid = JSONQueryService.stringToJson( qr ).getInt( "transid" );
        return Response.created( URI
                .create( info.getBaseUri() + "teller/transaction/" + transid ) ).entity( qr ).build();
    }
    
    @GET
    @Produces({ MediaType.APPLICATION_JSON })
    @Path("transaction/{tid}")
    public String getTransaction(@PathParam("tid") int tid){
        return teller.getTransaction( tid );
    }
}
