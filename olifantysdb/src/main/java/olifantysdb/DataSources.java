
package olifantysdb;

import javax.sql.DataSource;
import org.postgresql.ds.PGSimpleDataSource;

/**
 *
 * @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
 */
public class DataSources {
    static DataSource createPGDataSource() {
        PGSimpleDataSource source = new PGSimpleDataSource();
        System.out.println( "using pg data source" );
        source.setServerName( "localhost" );
        source.setDatabaseName( "olifantysbank" );
        source.setUser( "teller" );
        source.setPassword( "teller" );
        return source;
    }
}
