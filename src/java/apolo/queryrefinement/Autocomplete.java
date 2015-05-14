package apolo.queryrefinement;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.SortedSet;

import apolo.msc.Global_Configuration;

import com.aliasi.io.FileLineReader;
import com.aliasi.spell.AutoCompleter;
import com.aliasi.spell.FixedWeightEditDistance;
import com.aliasi.util.ScoredObject;

public class Autocomplete {
	
	private ArrayList<String> filenames;
	private Map<String,Integer> dictionary;
	private double matchWeight;
	private double insertWeight;
	private double substituteWeight;
	private double deleteWeight;
	private double transposeWeight;
	private FixedWeightEditDistance editDistance;
	private int maxResults;
	private int maxQueueSize;
	private double minScore;
	private AutoCompleter completer;
	
	public Autocomplete(){
		String path = System.getProperty("user.dir");
		String fullpath = path + File.separator + "src" + File.separator + "java" + File.separator + "apolo" + File.separator + "queryrefinement" + File.separator;
		this.filenames = new ArrayList<String>();
		this.filenames.add(fullpath + "artists.txt");
		this.filenames.add(fullpath + "releases.txt");
		//this.filenames.add(fullpath + "songs.txt");
		this.dictionary = new HashMap<String,Integer>(1000000);
		loadDictionaryFromDB();
		//loadDictionaryFromFile();
		this.matchWeight = 0.0;
        this.insertWeight = -10.0;
        this.substituteWeight = -10.0;
        this.deleteWeight = -10.0;
        this.transposeWeight = Double.NEGATIVE_INFINITY;
        this.editDistance = new FixedWeightEditDistance(matchWeight,deleteWeight,insertWeight,substituteWeight,transposeWeight);
        this.maxResults = 5;
        this.maxQueueSize = 10000;
        this.minScore = -25.0;
        completer = new AutoCompleter(dictionary, editDistance, maxResults, maxQueueSize, minScore);
	}
	
	private void loadDictionaryFromFile(){
		
		ArrayList<File> files = new ArrayList<File>();
		for(int i=0; i<this.filenames.size(); i++){
			files.add(new File(this.filenames.get(i)));
		}
		String[] lines = null;
		try{
			for(int m=0; m<files.size(); m++){
				lines = FileLineReader.readLineArray(files.get(m),"UTF-8");
				if(lines != null){
					for(String elem : lines){
						String name = elem;
						dictionary.put(elem, 2); //0 is for SONG
					}
				}
			}
		}catch(IOException ioe){
			System.out.println("ERROR: problem reading dictionary files on loadDictionary");
		}
		
	}
	
	public ArrayList<String> getCompletionsList(String input){
		SortedSet<ScoredObject<String>> completions = completer.complete(input);
		ArrayList<String> completionsList = new ArrayList<String>();
		for (ScoredObject<String> so : completions){
			completionsList.add(so.getObject());
		}
		return completionsList;
	}
	
	/***
	 * Loads the songs, artists and releases to the dictionary.
	 * It uses the existing DB table to obtain all songs, artists and release names.
	 */
	private void loadDictionaryFromDB(){
		ArrayList<String> queries = new ArrayList<String>();
		queries.add("SELECT title FROM artists_apolo");
		queries.add("SELECT title FROM releases_apolo");
		//queries.add("SELECT title FROM songs_apolo");
		
		Connection conn = getConnection();
		Statement stmt = null;
		ResultSet rs = null;
		
		for(int i=0; i<queries.size(); i++){
			executeAndAdd(queries.get(i), conn, stmt, rs);
		}
		
	}
	
	private void executeAndAdd(String q, Connection conn, Statement stmt, ResultSet rs){
		try {
		    stmt = conn.createStatement();
		    rs = stmt.executeQuery(q);
		    while(rs.next()){
		    	String val = rs.getString("title");
		    	val = val.substring(0,val.length()-1);
		    	dictionary.put(val, 2);
		    }
		}
		catch (SQLException ex){
		}
		finally {
		    if (rs != null) {
		        try {
		            rs.close();
		        } catch (SQLException sqlEx) { } // ignore

		        rs = null;
		    }

		    if (stmt != null) {
		        try {
		            stmt.close();
		        } catch (SQLException sqlEx) { } // ignore

		        stmt = null;
		    }
		}
	}
	
	public Connection getConnection(){
		Connection conn = null;
		try {
		    conn =
		       DriverManager.getConnection("jdbc:mysql://localhost/" +
					  					    Global_Configuration.MYSQL_DB + "?" +
					                        "user=" + Global_Configuration.MYSQL_USER + 
					                        "&password=" + Global_Configuration.MYSQL_PWD);
		} catch (SQLException ex) {
		}
		return conn;
	}
	
	/*
	public static void main(String a[]){
		System.out.println("Starting Autocomplete");
		Autocomplete ac = new Autocomplete();
		System.out.println("Autocomplete instance created");
		String q2 = "Ten Years";
		String q = "Silver";
		String q3 = "Pearl";
		ArrayList<String> comp;
		System.out.println("load finished");
		comp = ac.getCompletionsList(q);
		Iterator<String> it = comp.iterator();
		System.out.println("\n\nQuery: "+q);
		while(it.hasNext()){
			String rs = it.next();
			System.out.println(rs);
		}
		
		ArrayList<String> comp2 = ac.getCompletionsList(q2);
		Iterator<String> it2 = comp2.iterator();
		System.out.println("\n\nQuery: "+q2);
		while(it2.hasNext()){
			String rs = it2.next();
			System.out.println(rs);
		}
		
		ArrayList<String> comp3 = ac.getCompletionsList(q3);
		Iterator<String> it3 = comp3.iterator();
		System.out.println("\n\nQuery: "+q3);
		while(it3.hasNext()){
			String rs = it3.next();
			System.out.println(rs);
		}
	}
	*/

}
