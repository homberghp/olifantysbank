package jsonutil;

import javax.ws.rs.NotFoundException;

/**
 * Helper to turn normal queries into postgresql json returning queries.
 * <p>
 * The enum values wrap the queries such that the database produces one json
 * object, either a json array of json objects  or a single json object.
 * The resulting string can still be used as a basis for a prepared statement
 * ready for parameter
 * substitution.
 *
 * @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
 */
public enum JSONType {
    /**
     * JSON Obj wrapper.
     */
    JSONOBJECT( "with __t as (%s) select to_jsonb(__t) from __t" ) {
        @Override
        public void handleNothing() {
            throw new NotFoundException();
        }

    },
    /**
     * JSON array wrapper.
     */
    JSONARRAY( "with __t as (%s) select array_to_json(array_agg(__t),true) from __t" );

    private final String queryTemplate;

    /**
     * Take the template as cror argument.
     *
     * @param the template for this enum value.
     */
    private JSONType( String template ) {
        this.queryTemplate = template;
    }

    /**
     * Get the template string set in the ctor.
     *
     * @return the template string.
     */
    String getQueryTemplate() {
        return queryTemplate;
    }

    /**
     * Combine query with json wrapping call.
     *
     * @param baseQuery the 'normal query'
     *
     * @return the query wrapped such that the result is wrapped as json by the
     *         database.
     */
    public String getJsonQuery( String baseQuery ) {
        return String.format( queryTemplate, baseQuery );
    }

    /**
     * Hook for resource not available.
     */
    public void handleNothing() {

    }

}
