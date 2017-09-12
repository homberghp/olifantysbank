package olifantysdb;

import java.math.BigDecimal;
import javax.sql.DataSource;
import static olifantysdb.DataSources.createPGDataSource;

/**
 * Simple app to show insert works and produces a result.
 * @author hom
 */
public class TellerApp {

    static DataSource source = createPGDataSource();

    /**
     * App entry.
     * @param args to program.
     */
    public static void main( String[] args ) {

        int pietera = 6;
        int geerta = 4;
        BigDecimal price = new BigDecimal( "1.05" );
        String description = "soepje van de dag";
        Teller teller = new Teller( source );
        String transfer = teller.transfer( pietera, geerta, price, description );
        System.out.println( "transfer result = " + transfer );
    }
}
