//  Copyright © 2016 Gavan Chan. All rights reserved.

import Argo
import Foundation
import ReactiveSwift
import Result

private let apiKey: String = "402c2de16506bb59c7a6afc8b60778c2"

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
    withQuery query: Dictionary<String, String>) -> SignalProducer<URLRequest.Response, AnyError>
  {
    return session.reactive.data(with: request(for: endpoint, via: method, withQuery: query)).map { ($0.1 as! HTTPURLResponse, $0.0) }
  }

  func json(
    for endpoint: Endpoint,
    via method: URLRequest.Method,
    withQuery query: Dictionary<String, String>) -> SignalProducer<Argo.JSON, AnyError>
  {
    return response(for: endpoint, via: method, withQuery: query)
      .map { try! JSONSerialization.jsonObject(with: $0.1, options: .allowFragments) }
      .map(JSON.init)
  }
}
