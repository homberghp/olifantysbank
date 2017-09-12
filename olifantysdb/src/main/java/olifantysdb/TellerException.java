
package olifantysdb;

/**
 *
 * @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
 */
public class TellerException extends RuntimeException {

    /**
     * Creates a new instance of <code>TellerException</code> without detail
     * message.
     */
    public TellerException() {
    }

    /**
     * Constructs an instance of <code>TellerException</code> with the specified
     * detail message.
     *
     * @param msg the detail message.
     */
    public TellerException( String msg ) {
        super( msg );
    }

    public TellerException( String message, Throwable cause ) {
        super( message, cause );
    }

    public TellerException( String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace ) {
        super( message, cause, enableSuppression, writableStackTrace );
    }
    
}
