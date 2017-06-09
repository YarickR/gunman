using UnityEngine;
using System;
using System.Diagnostics;

public class GCTX : Singleton<GCTX> {


	protected GCTX () {} 

	public static void Log(object o) {
		if (Application.isEditor) {
			string __t =  System.DateTime.Now.ToString() + "(+" + Time.realtimeSinceStartup + " s) " + o.ToString();
			UnityEngine.Debug.Log(__t);
		} else {
			/*
			System.Diagnostics.Debug.WriteLine(String.Format("{0} ({1}) {2}\n\t{3}",System.DateTime.Now.ToString(), Time.realtimeSinceStartup, o.ToString(), __t));
			*/

			StackTrace __trace = new System.Diagnostics.StackTrace();
			string __t = __trace.ToString();

//			__t = __t.Substring(__t.LastIndexOf(" at "));
//			System.Diagnostics.Debug.WriteLine(String.Format("* {0} ({1}) #{2} * {3}\n{4}",System.DateTime.Now.ToString(), Time.realtimeSinceStartup, __uid, o.ToString(), __t));
			UnityEngine.Debug.Log(String.Format("* {0} ({1}) * {2}\n{3}",System.DateTime.Now.ToString(), Time.realtimeSinceStartup,  o.ToString(), __t));

		};
	}

}
