import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Text "mo:base/Text";
actor {
//    public type Message = Text;
   public type Message = {
       msg: Text;
       time: Time.Time;
   };
   public type Microblog = actor {
       follow: shared(Principal) -> async ();
       follows: shared query () -> async [Principal];
       post: shared (Text) -> async ();
       posts: shared query (Time.Time) -> async [Message];
       timeline : shared (Time.Time) -> async [Message];
   };

   stable var followed : List.List<Principal> = List.nil();
//    var followed : List.List<Principal> = List.nil();


   public shared func follow(id: Principal) : async () {
       followed := List.push(id, followed);
   };

   public shared query func follows() : async [Principal] {
      List.toArray(followed)  
   };

   stable var messages : List.List<Message> = List.nil();
//    var messages : List.List<Message> = List.nil();

   public shared (msg) func post(text: Text) : async () {
       assert(Principal.toText(msg.caller) == "lhhzc-wacws-ffzgw-5scj7-al3iu-m375e-46qbp-qusrw-vkzks-ct7jn-rqe" );
       var m1 = {
            msg = text;
            time = Time.now();
       };
    //    messages := List.push(text, messages)
     messages := List.push<Message>(m1, messages);

   };

   public shared query func posts(since: Time.Time) : async [Message] {
        List.toArray(List.filter<Message>(messages, func({time}) = time >= since ));
        // List.toArray(messages)
   };

   public shared func timeline(since:Time.Time) : async [Message] {
       var all : List.List<Message> = List.nil();

       for (id in Iter.fromList(followed)) {
           let canister : Microblog = actor(Principal.toText(id));
           let msgs = await canister.posts(since);
           for (msg in Iter.fromArray(msgs)) {
               all := List.push(msg, all)
           }
       };

       List.toArray(all);
   };
};
