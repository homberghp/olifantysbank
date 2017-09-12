/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package olifantysdb;

import java.math.BigDecimal;
import javax.json.Json;
import javax.json.JsonObject;
import jsonutil.JSONQueryService;
import static jsonutil.JSONQueryService.stringToJson;
import static olifantysdb.TellerApp.source;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
 */
public class TellerTest {

    JSONQueryService jqs = new JSONQueryService();

    /**
     * In this test we are happy when there is no exception.
     */
    @Test
    public void testTransfer() {
        int pietera = 6;
        int geerta = 4;
        BigDecimal price = new BigDecimal( "1.05" );
        String description = "soepje van de dag";
        Teller teller = new Teller( source );
        String transfer = teller.transfer( pietera, geerta, price, description );
        System.out.println( "transfer = " + transfer );
        JsonObject jso = stringToJson( transfer );
        BigDecimal debit = jso.getJsonNumber( "debit" ).bigDecimalValue();
        System.out.println( "transfer result = " + transfer );
        assertEquals( price, debit );
    }

    @Test
    public void testTransferJson() {
        Teller teller = new Teller( source );
        BigDecimal price = new BigDecimal( "6.50" );
        String job
                = Json.createObjectBuilder()
                        .add( "froma", 4 )
                        .add( "toa", 6 )
                        .add( "amount", price )
                        .add( "description", "hamburger" )
                        .build()
                        .toString();
        System.out.println( "job = " + job );
        String transfer = teller.transfer( job );
        JsonObject jso = stringToJson( transfer );
        BigDecimal debit = jso.getJsonNumber( "debit" ).bigDecimalValue();
        System.out.println( "transfer result = " + transfer );
        assertEquals( price, debit );
    }
    
    @Test
    public void testGetTransaction(){
        Teller teller = new Teller( source );
        String trans = teller.getTransaction( 2);
        System.out.println( "trans = " + trans );
    }
}
