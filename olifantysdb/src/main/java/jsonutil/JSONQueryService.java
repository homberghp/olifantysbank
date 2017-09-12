package jsonutil;

import java.io.StringReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.function.Function;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.sql.DataSource;

/**
 *
 * @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
 */
public class JSONQueryService {

    private final Function<SQLException, RuntimeException> exceptionWrapper;

    /**
     * How to wrap sql exceptions.
     *
     * @param exceptionWrapper
     */
    public JSONQueryService( Function<SQLException, RuntimeException> exceptionWrapper ) {
        this.exceptionWrapper = exceptionWrapper;
    }

    /**
     * Defaults to normal runtime exceptions.
     */
    public JSONQueryService() {
        this( sqle -> new RuntimeException( sqle ) );
    }

    /**
     * Queries with some query string and produces a JSON result.
     * The result will be one String containing a JSON payload.
     * <p>
     * Implementation detail: This
     * method is postgreSQL specific, because it relies on postgreSQL specific
     * functions such as {@code array_to_json} and {@code array_agg).
     * The query parameter is wrapped as a string into a CTE , whose
     * result is wrapped in the said methods.
     * The result of the wrapped query will always be one JSON object (which in the end is just a string).
     *
     * In case an array type response is expected from the query,
     * the database will always produce an array, even an empty one, which will look like "[]".
     * When thee jsontype parameter is JSONOBJECT, and the response code should be 404 (not found).
     *
     *
     * @param ds data source
     * @param query to send to the database
     * @param jtype to deal with the difference between array and oject responses.
     * @param args positional parameters to the query
     * @return a json string.
     */
    public String queryToJsonString( DataSource ds, String query, JSONType jtype, Object... args ) {
        String jsonQuery = jtype.getJsonQuery( query );
        System.out.println( "jsonQuery = " + jsonQuery );
        return querySimple( ds, jsonQuery, args );
    }

    /**
     * Do the work
     * @param ds data source to use
     * @param query to be executed after optional parameter substitution.
     * @param args for the query
     * @return the JSON object resulting from this query a as string
     */
    String querySimple( DataSource ds, String query, Object... args ) {
        String result = "";
        try ( final Connection connection = ds.getConnection();
                final PreparedStatement pst = connection.prepareStatement( query ) ) {
            int cid = 1;
            for ( Object arg : args ) {
                pst.setObject( cid++, arg );
            }
            // try with resources to also release resultset properly
            try ( final ResultSet rs = pst.executeQuery() ) {
                while ( rs.next() ) {
                    result += rs.getString( 1 );
                }
            }
            return result;
        } catch ( SQLException ex ) {
            Logger.getLogger( JSONQueryService.class.getName() ).log( Level.INFO, null, ex );
            throw this.exceptionWrapper.apply( ex );
        }
    }
    
    /**
     * Turn a string into a JSON Object for querying.
     * @param s the string to be parsed as JSON
     * @return the JSON object.
     */
    public static JsonObject stringToJson( String s ) {
        try ( JsonReader reader = Json.createReader( new StringReader( s ) ); ) {
            return ( JsonObject ) reader.read();
        }
    }
}
