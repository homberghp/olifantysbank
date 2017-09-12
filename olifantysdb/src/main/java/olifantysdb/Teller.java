package olifantysdb;

import java.math.BigDecimal;
import javax.json.JsonObject;
import javax.sql.DataSource;
import jsonutil.JSONQueryService;
import static jsonutil.JSONType.JSONOBJECT;
import static jsonutil.JSONType.JSONARRAY;

/**
 *
 * @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
 */
public class Teller {

    private final DataSource ds;
    private final JSONQueryService qs;

    public Teller( DataSource source ) {
        this.ds = source;
        this.qs = new JSONQueryService();

    }

    static final String TRANSFER_QUERY
            = "select * from transferv(?,?,?,?::text)";

    public String transfer( int fromAcount, int toAccount, BigDecimal price, String description ) {
        return qs.queryToJsonString( ds, TRANSFER_QUERY, JSONOBJECT, fromAcount, toAccount,
                price, description );
    }

    public String transfer( String job ) {
        JsonObject js = qs.stringToJson( job );
        System.out.println( "js = " + js );
        return transfer( js.getInt( "froma" ), js.getInt( "toa" ),
                js.getJsonNumber( "amount" ).bigDecimalValue(),
                js.getString( "description" ) );
    }

    static final String TRANSACTION_QUERY
            = "select * from my_transactions where trans_id=?";

    public String getTransaction( int tid ) {
        System.out.println( "TRANSACTION_QUERY = " + TRANSACTION_QUERY);
        return qs.queryToJsonString( ds, TRANSACTION_QUERY, JSONARRAY,  tid );
    }

}
