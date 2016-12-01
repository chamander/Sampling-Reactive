//  Copyright © 2016 Gavan Chan. All rights reserved.

import Argo
import Foundation
import RxCocoa
import RxSwift

fileprivate let apiKey: String = "402c2de16506bb59c7a6afc8b60778c2"

extension URLRequest {
  typealias Response = (HTTPURLResponse, Data)

  enum Method {
    case get
  }
}

protocol ClientProtocol {
  associatedtype Endpoint

  var base: URL { get }
  var session: URLSession { get }

  func request(
    for endpoint: Endpoint,
    via method: URLRequest.Method,
    withQuery query: Dictionary<String, String>) -> URLRequest
}

extension ClientProtocol where Endpoint: RawRepresentable, Endpoint.RawValue == String {
  func request(
    for endpoint: Endpoint,
    via method: URLRequest.Method,
    withQuery query: Dictionary<String, String>) -> URLRequest
  {
    var url: URL = base.appendingPathComponent(endpoint.rawValue)

    if var components: URLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
      var query: Dictionary<String, String> = query
      query.updateValue(apiKey, forKey: "APPID") // Insert the key required by the API
      components.query = query.reduce(String()) { accum, next in
        "\(accum)\(next.key)=\(next.value)&"
      }
      url = components.url!
    }

    return URLRequest(url: url)
  }

  func response(
    for endpoint: Endpoint,
    via method: URLRequest.Method,
    withQuery query: Dictionary<String, String>) -> Observable<URLRequest.Response>
  {
    return session.rx.response(request: request(for: endpoint, via: method, withQuery: query))
  }

  func json(
    for endpoint: Endpoint,
    via method: URLRequest.Method,
    withQuery query: Dictionary<String, String>) -> Observable<Argo.JSON>
  {
    return session.rx.json(request: request(for: endpoint, via: method, withQuery: query)).map(JSON.init)
  }
}
