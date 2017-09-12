package olifantysfxclient;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Tab;
import javafx.scene.control.TabPane;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.Pane;
import javafx.stage.Stage;

/**
 * Simple app to show how fx:include works.
 *
 * @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
 */
public class TabbedApp extends Application {

    @Override
    public void start( Stage primaryStage ) throws Exception {
        FXMLLoader fxmlLoader = new FXMLLoader();
        fxmlLoader.setLocation(
                TabbedApp.class.getResource( "TabbedApp.fxml" ) );
        final AnchorPane borderPane = fxmlLoader.load();
        Scene scene = new Scene( borderPane, 800, 600 );
        primaryStage.setTitle( "Tabbed Example" );
        primaryStage.setScene( scene );
        primaryStage.show();
        nodes( borderPane );
    }

    void nodes( final Pane parent ) {
        for ( Node node : parent.getChildren() ) {
                System.out.println( "a t = " + node +" type "+node.getClass().getName());
            if ( node instanceof Pane ) {
                nodes( ( Pane ) node );
            } else if ( node instanceof TabPane ) {
                Node t = ( ( TabPane ) node ).getTabs().get( 0 ).getContent();
                System.out.println( "b t = " + t +" type "+t.getClass().getName());
                if ( t instanceof Pane ) {
                    nodes( ( Pane ) t );
                }
            } 
        }
    }

    /**
     * Entrypoint of application.
     *
     * @param args parameters to application.
     */
    public static void main( String[] args ) {
        launch( args );
    }
}
